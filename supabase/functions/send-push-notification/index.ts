import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ── Types ─────────────────────────────────────────────────────────────────────

interface RequestBody {
  user_ids: string[];          // auth.users UUIDs
  title: string;
  message: string;
  channel: 'push' | 'in_app' | 'both';
  group_id?: number;
  reference_type?: string;
  reference_id?: number;
  metadata?: Record<string, unknown>;
  notification_type?: string;
  image_url?: string;
  /// Updates an unread inbox row with this key instead of inserting another.
  alert_key?: string;
  /// Audience label stored on an admin send: all, group, event, list, individual.
  target_type?: string;
}

interface FcmMessage {
  token: string;
  notification: { title: string; body: string; image?: string };
  data?: Record<string, string>;
  android?: {
    priority: string;
    notification?: { image: string };
  };
  apns?: {
    payload: { aps: { sound: string; badge: number; 'mutable-content'?: number } };
    fcm_options?: { image: string };
  };
}

// ── FCM HTTP v1 helper ────────────────────────────────────────────────────────

async function getAccessToken(serviceAccountJson: string): Promise<string> {
  const sa = JSON.parse(serviceAccountJson);

  const header = { alg: 'RS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };

  const encode = (obj: unknown) =>
    btoa(JSON.stringify(obj)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

  const signingInput = `${encode(header)}.${encode(payload)}`;

  // Import private key
  const keyData = sa.private_key
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\n/g, '');

  const binaryKey = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryKey,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const jwt = `${signingInput}.${btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')}`;

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenRes.json();
  if (!tokenData.access_token) {
    throw new Error(`FCM auth failed: ${JSON.stringify(tokenData)}`);
  }
  return tokenData.access_token;
}

async function sendFcmBatch(
  tokens: string[],
  title: string,
  body: string,
  projectId: string,
  accessToken: string,
  data?: Record<string, string>,
  imageUrl?: string,
): Promise<{ sent: number; failed: number }> {
  let sent = 0;
  let failed = 0;
  const batchSize = 500;

  for (let i = 0; i < tokens.length; i += batchSize) {
    const batch = tokens.slice(i, i + batchSize);

    const messages: FcmMessage[] = batch.map((token) => ({
      token,
      notification: { title, body, ...(imageUrl ? { image: imageUrl } : {}) },
      data: data ?? {},
      android: {
        priority: 'high',
        ...(imageUrl ? { notification: { image: imageUrl } } : {}),
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            ...(imageUrl ? { 'mutable-content': 1 } : {}),
          },
        },
        ...(imageUrl ? { fcm_options: { image: imageUrl } } : {}),
      },
    }));

    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    await Promise.all(
      messages.map(async (msg) => {
        const res = await fetch(url, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ message: msg }),
        });
        if (res.ok) {
          sent++;
        } else {
          const err = await res.json();
          console.error('FCM send error:', JSON.stringify(err));
          failed++;
        }
      }),
    );
  }

  return { sent, failed };
}

// ── Main handler ──────────────────────────────────────────────────────────────

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body: RequestBody = await req.json();
    const { user_ids, title, message, channel, group_id, reference_type, reference_id, metadata, notification_type } = body;
    const imageUrl = body.image_url?.trim() || undefined;
    const alertKey = body.alert_key?.trim() || undefined;
    const resolvedType = notification_type ?? (group_id ? 'group_announcement' : 'admin_announcement');
    const recordSend = resolvedType === 'admin_announcement' || resolvedType === 'group_announcement';
    const rowMetadata: Record<string, unknown> = {
      ...(metadata ?? {}),
      ...(imageUrl && resolvedType !== 'group_message' ? { image_url: imageUrl } : {}),
      ...(alertKey ? { alert_key: alertKey } : {}),
    };
    const hasMetadata = Object.keys(rowMetadata).length > 0;

    if (!user_ids?.length || !title || !message || !channel) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Service-role client (bypasses RLS)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    let inAppSent = 0;
    let pushSent = 0;
    let pushFailed = 0;
    let sendId: number | null = null;

    if (recordSend) {
      let createdBy: string | null = null;
      const authHeader = req.headers.get('Authorization');
      const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
      if (authHeader && anonKey) {
        const userClient = createClient(Deno.env.get('SUPABASE_URL')!, anonKey, {
          global: { headers: { Authorization: authHeader } },
        });
        const { data: userData } = await userClient.auth.getUser();
        createdBy = userData.user?.id ?? null;
      }

      const { data: sendRow, error: sendError } = await supabase
        .from('cc_notification_sends')
        .insert({
          created_by: createdBy,
          channel,
          type: resolvedType,
          title,
          message,
          image_url: imageUrl ?? null,
          group_id: group_id ?? null,
          target_type: body.target_type ?? null,
          recipient_count: user_ids.length,
          in_app_sent: 0,
          push_sent: 0,
          push_failed: 0,
        })
        .select('id')
        .single();
      if (sendError) throw new Error(`Send log failed: ${sendError.message}`);
      sendId = sendRow.id as number;
    }

    // ── In-App notifications ─────────────────────────────────────────────────
    if (channel === 'in_app' || channel === 'both') {
      // Filter users who have in_app_global enabled (default true if no row)
      const { data: disabledPrefs } = await supabase
        .from('cc_notification_preferences')
        .select('user_id')
        .in('user_id', user_ids)
        .eq('notification_type', 'in_app_global')
        .eq('enabled', false);

      const disabledIds = new Set((disabledPrefs ?? []).map((p: { user_id: string }) => p.user_id));
      const inAppRecipients = user_ids.filter((id) => !disabledIds.has(id));

      let pendingRecipients = inAppRecipients;
      if (alertKey && inAppRecipients.length > 0) {
        const { data: existing, error: existingError } = await supabase
          .from('cc_notifications')
          .select('id, user_id')
          .in('user_id', inAppRecipients)
          .eq('is_read', false)
          .filter('metadata->>alert_key', 'eq', alertKey);
        if (existingError) throw new Error(`Alert lookup failed: ${existingError.message}`);

        const existingRows = existing ?? [];
        if (existingRows.length > 0) {
          const { error: updateError } = await supabase
            .from('cc_notifications')
            .update({
              title,
              message,
              created_at: new Date().toISOString(),
            })
            .in('id', existingRows.map((row: { id: number }) => row.id));
          if (updateError) throw new Error(`Alert update failed: ${updateError.message}`);
          inAppSent += existingRows.length;
          const updatedUsers = new Set(existingRows.map((row: { user_id: string }) => row.user_id));
          pendingRecipients = inAppRecipients.filter((id) => !updatedUsers.has(id));
        }
      }

      if (pendingRecipients.length > 0) {
        const rows = pendingRecipients.map((userId) => ({
          user_id: userId,
          type: resolvedType,
          title,
          message,
          reference_type: reference_type ?? null,
          reference_id: reference_id ?? null,
          group_id: group_id ?? null,
          send_id: sendId,
          metadata: hasMetadata ? rowMetadata : null,
          is_read: false,
        }));

        const { error } = await supabase.from('cc_notifications').insert(rows);
        if (error) throw new Error(`In-app insert failed: ${error.message}`);
        inAppSent += pendingRecipients.length;
      }
    }

    // ── Push notifications ───────────────────────────────────────────────────
    if (channel === 'push' || channel === 'both') {
      const serviceAccountJson = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON');
      if (!serviceAccountJson) {
        throw new Error('FCM_SERVICE_ACCOUNT_JSON secret not configured');
      }

      const sa = JSON.parse(serviceAccountJson);
      const projectId = sa.project_id;

      // Filter users who have push_global enabled (default true if no row)
      const { data: disabledPrefs } = await supabase
        .from('cc_notification_preferences')
        .select('user_id')
        .in('user_id', user_ids)
        .eq('notification_type', 'push_global')
        .eq('enabled', false);

      const disabledIds = new Set((disabledPrefs ?? []).map((p: { user_id: string }) => p.user_id));
      const pushRecipients = user_ids.filter((id) => !disabledIds.has(id));

      if (pushRecipients.length > 0) {
        // Get FCM tokens
        const { data: tokenRows, error: tokErr } = await supabase
          .from('cc_device_tokens')
          .select('fcm_token')
          .in('user_id', pushRecipients);

        if (tokErr) throw new Error(`Token lookup failed: ${tokErr.message}`);

        const tokens = (tokenRows ?? []).map((r: { fcm_token: string }) => r.fcm_token);

        if (tokens.length > 0) {
          const accessToken = await getAccessToken(serviceAccountJson);
          const result = await sendFcmBatch(tokens, title, message, projectId, accessToken, {
            group_id: group_id?.toString() ?? '',
            channel: channel,
            ...(imageUrl ? { image_url: imageUrl } : {}),
          }, imageUrl);
          pushSent = result.sent;
          pushFailed = result.failed;
        }
      }
    }

    if (sendId != null) {
      const { error: countError } = await supabase
        .from('cc_notification_sends')
        .update({
          in_app_sent: inAppSent,
          push_sent: pushSent,
          push_failed: pushFailed,
        })
        .eq('id', sendId);
      if (countError) console.error('Send count update failed:', countError.message);
    }

    return new Response(
      JSON.stringify({ success: true, in_app_sent: inAppSent, push_sent: pushSent, push_failed: pushFailed, send_id: sendId }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    console.error('send-push-notification error:', e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
