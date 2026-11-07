import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import {
  claimLog,
  emailConfig,
  emailShell,
  escapeHtml,
  firstName,
  isFacilitatorRole,
  loadPrefs,
  prefersPortuguese,
  sendEmail,
} from '../_shared/facilitator_prefs.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function canSeeMessage(
  memberId: string,
  isFacilitator: boolean,
  sharing: { user_id: string | null; recipient_user_id: string | null; audience: string | null },
): boolean {
  if (sharing.audience === 'facilitators') {
    return isFacilitator || sharing.user_id === memberId;
  }
  if (sharing.recipient_user_id == null) return true;
  return sharing.recipient_user_id === memberId || sharing.user_id === memberId;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) return json({ error: 'Missing authorization' }, 401);

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) return json({ error: 'Not signed in' }, 401);

    const body = await req.json();
    const sharingId = Number(body.sharing_id);
    if (!Number.isFinite(sharingId)) return json({ error: 'sharing_id required' }, 400);

    const supabase = createClient(supabaseUrl, serviceKey);
    const { data: sharing, error: sharingError } = await supabase
      .from('cc_sharings')
      .select('id, type, title, text, group_id, user_id, recipient_user_id, audience')
      .eq('id', sharingId)
      .maybeSingle();
    if (sharingError) throw new Error(sharingError.message);
    if (!sharing || sharing.type !== 'notification' || sharing.group_id == null) {
      return json({ skipped: true });
    }
    if (sharing.user_id !== userData.user.id) {
      return json({ error: 'Not the message author' }, 403);
    }

    const { data: members, error: membersError } = await supabase
      .from('cc_group_members')
      .select('user_id, user_role')
      .eq('group_id', sharing.group_id);
    if (membersError) throw new Error(membersError.message);

    const visible = (members ?? []).filter((member) =>
      typeof member.user_id === 'string' &&
      member.user_id !== sharing.user_id &&
      canSeeMessage(member.user_id, isFacilitatorRole(member.user_role), sharing)
    );

    const pushIds: string[] = [];
    const emailIds: string[] = [];
    for (const member of visible) {
      const userId = member.user_id as string;
      const facilitator = isFacilitatorRole(member.user_role);
      const personal = sharing.audience === 'facilitators' || sharing.recipient_user_id === userId;
      if (facilitator && personal) {
        const prefs = await loadPrefs(supabase, userId, sharing.group_id);
        if (prefs.notify_messages) pushIds.push(userId);
        if (sharing.audience === 'facilitators' && prefs.email_member_message) emailIds.push(userId);
      } else {
        pushIds.push(userId);
      }
    }

    const { data: group } = await supabase
      .from('cc_groups')
      .select('name')
      .eq('id', sharing.group_id)
      .maybeSingle();
    const groupName = group?.name ?? 'New message';

    let pushed = 0;
    if (pushIds.length > 0) {
      const pushRes = await fetch(`${supabaseUrl}/functions/v1/send-push-notification`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${serviceKey}`,
          apikey: serviceKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_ids: pushIds,
          title: groupName,
          message: String(sharing.title ?? 'New message').slice(0, 120),
          channel: 'push',
          group_id: sharing.group_id,
          reference_type: 'group_message',
          reference_id: sharing.id,
        }),
      });
      if (!pushRes.ok) {
        console.error('send-push-notification failed:', await pushRes.text());
      } else {
        pushed = pushIds.length;
      }
    }

    let mailed = 0;
    if (emailIds.length > 0) {
      const mail = await emailConfig(supabase);
      const { data: author } = await supabase
        .from('cc_members')
        .select('display_name, first_name')
        .eq('auth_user_id', sharing.user_id)
        .maybeSingle();
      const authorLabel = firstName(author) || 'Alguém';
      const excerpt = String(sharing.text ?? '').replace(/\s+/g, ' ').slice(0, 280);
      const title = String(sharing.title ?? '').slice(0, 120);

      if (mail.apiKey) {
        for (const userId of emailIds) {
          const claimed = await claimLog(supabase, userId, `member_message:${sharingId}`);
          if (!claimed) continue;
          const { data: recipient } = await supabase
            .from('cc_members')
            .select('email, language')
            .eq('auth_user_id', userId)
            .maybeSingle();
          const email = recipient?.email?.trim();
          if (!email) continue;
          const portuguese = prefersPortuguese(recipient?.language);
          const subject = portuguese
            ? `Nova mensagem em ${groupName}`
            : `New message in ${groupName}`;
          const messageLink = `https://invite.callofthetime.org/message?id=${sharingId}`;
          const openLabel = portuguese ? 'Abrir a mensagem' : 'Open the message';
          const html = emailShell(subject, `
            <p>${escapeHtml(portuguese
              ? `${authorLabel} escreveu uma mensagem só para os facilitadores de ${groupName}.`
              : `${authorLabel} wrote a message only the facilitators of ${groupName} can see.`)}</p>
            <h2 style="margin:16px 0 8px;font-size:18px;">${escapeHtml(title)}</h2>
            <p style="color:#444;">${escapeHtml(excerpt)}</p>
            <p style="margin:24px 0 0;">
              <a href="${messageLink}" style="display:inline-block;padding:12px 24px;background-color:#e8734a;color:#ffffff;text-decoration:none;border-radius:8px;font-weight:600;">${escapeHtml(openLabel)}</a>
            </p>
          `);
          await sendEmail({ apiKey: mail.apiKey, from: mail.from, to: email, subject, html });
          mailed += 1;
        }
      }
    }

    return json({ success: true, pushed, mailed });
  } catch (error) {
    console.error('notify-group-message error:', error);
    return json({ error: String(error) }, 500);
  }
});
