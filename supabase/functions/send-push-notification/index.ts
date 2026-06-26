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
}

interface FcmMessage {
  token: string;
  notification: { title: string; body: string };
  data?: Record<string, string>;
  android?: { priority: string };
  apns?: { payload: { aps: { sound: string; badge: number } } };
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
): Promise<{ sent: number; failed: number }> {
  let sent = 0;
  let failed = 0;
  const batchSize = 500;

  for (let i = 0; i < tokens.length; i += batchSize) {
    const batch = tokens.slice(i, i + batchSize);

    const messages: FcmMessage[] = batch.map((token) => ({
      token,
      notification: { title, body },
      data: data ?? {},
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default', badge: 1 } } },
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
    const { user_ids, title, message, channel, group_id, reference_type, reference_id, metadata } = body;

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

      if (inAppRecipients.length > 0) {
        const rows = inAppRecipients.map((userId) => ({
          user_id: userId,
          type: group_id ? 'group_announcement' : 'admin_announcement',
          title,
          message,
          reference_type: reference_type ?? null,
          reference_id: reference_id ?? null,
          group_id: group_id ?? null,
          metadata: metadata ?? null,
          is_read: false,
        }));

        const { error } = await supabase.from('cc_notifications').insert(rows);
        if (error) throw new Error(`In-app insert failed: ${error.message}`);
        inAppSent = inAppRecipients.length;
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
          });
          pushSent = result.sent;
          pushFailed = result.failed;
        }
      }
    }

    return new Response(
      JSON.stringify({ success: true, in_app_sent: inAppSent, push_sent: pushSent, push_failed: pushFailed }),
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
