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

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const authHeader = req.headers.get('Authorization') ?? '';
    const token = authHeader.replace(/^Bearer\s+/i, '');
    const serviceCall = token === serviceKey;

    const supabase = createClient(supabaseUrl, serviceKey);
    let callerId: string | null = null;
    if (!serviceCall) {
      const userClient = createClient(supabaseUrl, anonKey, {
        global: { headers: { Authorization: authHeader } },
      });
      const { data: userData, error: userError } = await userClient.auth.getUser();
      if (userError || !userData.user) return json({ error: 'Not signed in' }, 401);
      callerId = userData.user.id;
    }

    const body = await req.json();
    const sharingId = Number(body.sharing_id);
    if (!Number.isFinite(sharingId)) return json({ error: 'sharing_id required' }, 400);

    const { data: sharing, error: sharingError } = await supabase
      .from('cc_sharings')
      .select('id, type, title, text, group_id, user_id, moderation_status')
      .eq('id', sharingId)
      .maybeSingle();
    if (sharingError) throw new Error(sharingError.message);
    if (!sharing || sharing.group_id == null || sharing.type === 'notification') {
      return json({ skipped: true });
    }
    if (sharing.type !== 'experience' && sharing.type !== 'sharing') {
      return json({ skipped: true });
    }

    const requested = body.event === 'pending' || body.event === 'published' ? body.event : null;
    const event = requested ??
      (sharing.moderation_status === 'awaiting_approval'
        ? 'pending'
        : sharing.moderation_status === 'approved'
        ? 'published'
        : null);
    if (!event) return json({ skipped: true, reason: 'not visible yet' });
    if (event === 'pending' && sharing.moderation_status !== 'awaiting_approval') {
      return json({ skipped: true, reason: 'status moved on' });
    }
    if (event === 'published' && sharing.moderation_status !== 'approved') {
      return json({ skipped: true, reason: 'not published' });
    }

    if (!serviceCall && callerId !== sharing.user_id) {
      const { data: callerMembership } = await supabase
        .from('cc_group_members')
        .select('user_role')
        .eq('group_id', sharing.group_id)
        .eq('user_id', callerId)
        .maybeSingle();
      if (!isFacilitatorRole(callerMembership?.user_role)) {
        return json({ error: 'Not allowed' }, 403);
      }
    }

    const { data: members, error: membersError } = await supabase
      .from('cc_group_members')
      .select('user_id, user_role')
      .eq('group_id', sharing.group_id);
    if (membersError) throw new Error(membersError.message);

    const facilitators = (members ?? []).filter((member) =>
      typeof member.user_id === 'string' &&
      member.user_id !== sharing.user_id &&
      isFacilitatorRole(member.user_role)
    );
    if (facilitators.length === 0) return json({ skipped: true, reason: 'no facilitators' });

    const { data: author } = await supabase
      .from('cc_members')
      .select('display_name, first_name, email, language')
      .eq('auth_user_id', sharing.user_id)
      .maybeSingle();
    const authorLabel = firstName(author) || 'Alguém';

    const { data: group } = await supabase
      .from('cc_groups')
      .select('name')
      .eq('id', sharing.group_id)
      .maybeSingle();
    const groupName = group?.name ?? 'Good Wishes';
    const title = String(sharing.title ?? '').slice(0, 120);
    const excerpt = String(sharing.text ?? '').replace(/\s+/g, ' ').slice(0, 280);

    const mail = event === 'published' ? await emailConfig(supabase) : null;
    let pushed = 0;
    let mailed = 0;

    for (const facilitator of facilitators) {
      const userId = facilitator.user_id as string;
      const prefs = await loadPrefs(supabase, userId, sharing.group_id);
      const claimed = await claimLog(supabase, userId, `${event}:${sharingId}`);
      if (!claimed) continue;

      if (prefs.notify_new_experiences) {
        const portuguese = prefersPortuguese(
          (await supabase.from('cc_members').select('language').eq('auth_user_id', userId).maybeSingle()).data?.language,
        );
        const pushTitle = groupName;
        const pushBody = event === 'pending'
          ? (portuguese
            ? `${authorLabel} enviou uma experiência para aprovação`
            : `${authorLabel} sent an experience for approval`)
          : (portuguese
            ? `Nova experiência: ${title || 'sem título'}`
            : `New experience: ${title || 'untitled'}`);

        const pushRes = await fetch(`${supabaseUrl}/functions/v1/send-push-notification`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${serviceKey}`,
            apikey: serviceKey,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            user_ids: [userId],
            title: pushTitle,
            message: pushBody,
            channel: 'both',
            notification_type: event === 'pending' ? 'experience_pending' : 'experience_published',
            group_id: sharing.group_id,
            reference_type: 'experience',
            reference_id: sharing.id,
          }),
        });
        if (pushRes.ok) pushed += 1;
        else console.error('experience push failed:', await pushRes.text());
      }

      if (event === 'published' && prefs.email_each_experience && mail?.apiKey) {
        const { data: recipient } = await supabase
          .from('cc_members')
          .select('email, language')
          .eq('auth_user_id', userId)
          .maybeSingle();
        const email = recipient?.email?.trim();
        if (!email) continue;
        const portuguese = prefersPortuguese(recipient?.language);
        const subject = portuguese
          ? `Nova experiência em ${groupName}`
          : `New experience in ${groupName}`;
        const html = emailShell(subject, `
          <p>${escapeHtml(portuguese
            ? `${authorLabel} publicou uma experiência em ${groupName}.`
            : `${authorLabel} published an experience in ${groupName}.`)}</p>
          <h2 style="margin:16px 0 8px;font-size:18px;">${escapeHtml(title || (portuguese ? 'Sem título' : 'Untitled'))}</h2>
          <p style="color:#444;">${escapeHtml(excerpt)}</p>
          <p>${escapeHtml(portuguese
            ? 'Abra o app Good Wishes para ler e deixar um comentário.'
            : 'Open the Good Wishes app to read it and leave a comment.')}</p>
        `);
        await sendEmail({ apiKey: mail.apiKey, from: mail.from, to: email, subject, html });
        mailed += 1;
      }
    }

    return json({ success: true, event, pushed, mailed });
  } catch (error) {
    console.error('notify-facilitator-experience error:', error);
    return json({ error: String(error) }, 500);
  }
});
