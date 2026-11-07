import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';
import {
  claimLog,
  emailConfig,
  emailShell,
  escapeHtml,
  firstName,
  isFacilitatorRole,
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

type Period = 'daily' | 'weekly';

function windowFor(period: Period) {
  const now = new Date();
  const hours = period === 'daily' ? 24 : 24 * 7;
  const start = new Date(now.getTime() - hours * 3600 * 1000);
  const previousStart = new Date(start.getTime() - hours * 3600 * 1000);
  const day = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'America/Sao_Paulo',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(now);
  return {
    now: now.toISOString(),
    start: start.toISOString(),
    previousStart: previousStart.toISOString(),
    key: `${period}:${day}`,
    day,
  };
}

function inRange(value: string | null, start: string, end: string): boolean {
  if (!value) return false;
  return value >= start && value < end;
}

function list(items: string[], empty: string): string {
  if (items.length === 0) return `<p style="margin:4px 0 12px;color:#666;">${escapeHtml(empty)}</p>`;
  return `<ul style="margin:4px 0 12px;padding-left:18px;">${
    items.map((item) => `<li>${escapeHtml(item)}</li>`).join('')
  }</ul>`;
}

async function groupSection(
  supabase: SupabaseClient,
  groupId: number,
  groupName: string,
  period: Period,
  portuguese: boolean,
  bounds: ReturnType<typeof windowFor>,
): Promise<string> {
  const { data: memberships } = await supabase
    .from('cc_group_members')
    .select('user_id, user_role, created_at')
    .eq('group_id', groupId);
  const members = memberships ?? [];
  const facilitatorIds = new Set(
    members.filter((member) => isFacilitatorRole(member.user_role)).map((member) => member.user_id),
  );
  const userIds = members.map((member) => member.user_id).filter((id): id is string => typeof id === 'string');

  let profiles: Array<Record<string, unknown>> = [];
  if (userIds.length > 0) {
    const engagement = await supabase
      .from('cc_view_members_engagement')
      .select('auth_user_id, first_name, display_name, effective_last_access, never_accessed')
      .in('auth_user_id', userIds);
    if (!engagement.error) {
      profiles = engagement.data ?? [];
    } else {
      const fallback = await supabase
        .from('cc_members')
        .select('auth_user_id, first_name, display_name, last_access')
        .in('auth_user_id', userIds);
      profiles = (fallback.data ?? []).map((row) => ({
        ...row,
        effective_last_access: row.last_access,
        never_accessed: row.last_access == null,
      }));
    }
  }

  const profileById = new Map(profiles.map((row) => [String(row.auth_user_id), row]));
  const fourteenDaysAgo = new Date(Date.now() - 14 * 24 * 3600 * 1000).toISOString();

  let active = 0;
  let never = 0;
  const cooling: string[] = [];
  for (const userId of userIds) {
    const profile = profileById.get(userId);
    const last = profile?.effective_last_access as string | null | undefined;
    const neverAccessed = profile?.never_accessed === true || !last;
    if (neverAccessed) {
      never += 1;
    } else {
      active += 1;
      if (last < fourteenDaysAgo) {
        const name = firstName({
          display_name: typeof profile?.display_name === 'string' ? profile.display_name : null,
          first_name: typeof profile?.first_name === 'string' ? profile.first_name : null,
        });
        if (name && cooling.length < 5) cooling.push(name);
      }
    }
  }

  const joinedNow = members.filter((member) => inRange(member.created_at, bounds.start, bounds.now)).length;
  const joinedBefore = members.filter((member) => inRange(member.created_at, bounds.previousStart, bounds.start)).length;

  const { count: pendingInvites } = await supabase
    .from('invitations')
    .select('id', { count: 'exact', head: true })
    .eq('group_id', groupId)
    .eq('status', 'pending');

  const { data: sharings } = await supabase
    .from('cc_sharings')
    .select('id, title, user_id, created_at, moderation_status, type, audience')
    .eq('group_id', groupId)
    .in('type', ['experience', 'sharing', 'notification']);

  const rows = sharings ?? [];
  const experiences = rows.filter((row) => row.type !== 'notification');
  const published = experiences.filter((row) => row.moderation_status === 'approved' || row.moderation_status == null);
  const pending = experiences.filter((row) => row.moderation_status === 'awaiting_approval');
  const publishedNow = published.filter((row) => inRange(row.created_at, bounds.start, bounds.now));
  const publishedBefore = published.filter((row) => inRange(row.created_at, bounds.previousStart, bounds.start));

  const experienceIds = experiences.map((row) => row.id).filter((id) => id != null);
  const { data: comments } = experienceIds.length === 0
    ? { data: [] }
    : await supabase
      .from('cc_comments')
      .select('sharing_id, user_id, created_at')
      .in('sharing_id', experienceIds);

  const commentRows = comments ?? [];
  const commentsBySharing = new Map<number, { user_id: string; created_at: string }[]>();
  for (const comment of commentRows) {
    const bucket = commentsBySharing.get(comment.sharing_id) ?? [];
    bucket.push(comment);
    commentsBySharing.set(comment.sharing_id, bucket);
  }

  const uncommented = publishedNow.filter((row) => (commentsBySharing.get(row.id) ?? []).length === 0);
  const newTitles = publishedNow.slice(0, 5).map((row) => {
    const author = profileById.get(String(row.user_id));
    const name = firstName({
      display_name: typeof author?.display_name === 'string' ? author.display_name : null,
      first_name: typeof author?.first_name === 'string' ? author.first_name : null,
    });
    const label = row.title || (portuguese ? 'Sem título' : 'Untitled');
    return name ? `${label} — ${name}` : label;
  });
  const pendingTitles = pending.slice(0, 5).map((row) => row.title || (portuguese ? 'Sem título' : 'Untitled'));

  let topTitle = '';
  if (period === 'weekly') {
    let best = 0;
    for (const row of published) {
      const count = (commentsBySharing.get(row.id) ?? []).filter((comment) =>
        inRange(comment.created_at, bounds.start, bounds.now)
      ).length;
      if (count > best) {
        best = count;
        topTitle = row.title || (portuguese ? 'Sem título' : 'Untitled');
      }
    }
  }

  const direct = rows.filter((row) => row.type === 'notification' && row.audience === 'facilitators');
  const directNow = direct.filter((row) => inRange(row.created_at, bounds.start, bounds.now));
  const directIds = directNow.map((row) => row.id);
  const { data: directComments } = directIds.length === 0
    ? { data: [] }
    : await supabase.from('cc_comments').select('sharing_id, user_id').in('sharing_id', directIds);
  const answered = new Set(
    (directComments ?? [])
      .filter((comment) => facilitatorIds.has(comment.user_id))
      .map((comment) => comment.sharing_id),
  );
  const unansweredDirect = directNow.filter((row) => !answered.has(row.id)).length;

  const silent = publishedNow.length === 0 && joinedNow === 0;
  let action: string;
  if (pending.length > 0) {
    action = portuguese
      ? `Há ${pending.length} experiência(s) esperando sua aprovação.`
      : `${pending.length} experience(s) are waiting for your approval.`;
  } else if (unansweredDirect > 0) {
    action = portuguese
      ? `${unansweredDirect} mensagem(ns) direta(s) ainda sem a sua resposta.`
      : `${unansweredDirect} direct message(s) still need your reply.`;
  } else if (uncommented.length > 0) {
    action = portuguese
      ? `${uncommented.length} experiência(s) nova(s) ainda sem comentário. Um comentário seu costuma destravar o grupo.`
      : `${uncommented.length} new experience(s) still have no comment. One comment from you usually opens the group up.`;
  } else if (silent) {
    action = portuguese
      ? 'O grupo ficou em silêncio neste período. Uma mensagem curta sua costuma reabrir a conversa.'
      : 'The group was quiet in this period. A short message from you usually reopens the conversation.';
  } else if (never > 0) {
    action = portuguese
      ? `${never} pessoa(s) ainda não abriram o app.`
      : `${never} people have not opened the app yet.`;
  } else {
    action = portuguese
      ? 'O grupo seguiu em movimento. Vale reconhecer quem compartilhou.'
      : 'The group kept moving. It is worth naming the people who shared.';
  }

  const delta = period === 'weekly'
    ? (portuguese
      ? `<p>Experiências novas: ${publishedNow.length} (semana anterior: ${publishedBefore.length}). Novas pessoas: ${joinedNow} (semana anterior: ${joinedBefore}).</p>`
      : `<p>New experiences: ${publishedNow.length} (previous week: ${publishedBefore.length}). New people: ${joinedNow} (previous week: ${joinedBefore}).</p>`)
    : '';

  const top = topTitle
    ? `<p><strong>${portuguese ? 'Mais comentada' : 'Most commented'}:</strong> ${escapeHtml(topTitle)}</p>`
    : '';

  const labels = portuguese
    ? {
      people: 'Pessoas no grupo',
      active: 'Ativas',
      never: 'Nunca abriram o app',
      invites: 'Convites ainda não aceitos',
      total: 'Experiências publicadas',
      fresh: period === 'daily' ? 'Experiências novas nas últimas 24 horas' : 'Experiências novas na semana',
      waiting: 'Aguardando aprovação',
      quiet: 'Novas sem comentário',
      joined: 'Pessoas que entraram no período',
      cooling: 'Sem acesso há 14 dias ou mais',
      direct: 'Mensagens diretas do período sem resposta',
      none: 'Nenhuma',
    }
    : {
      people: 'People in the group',
      active: 'Active',
      never: 'Never opened the app',
      invites: 'Invites not accepted yet',
      total: 'Published experiences',
      fresh: period === 'daily' ? 'New experiences in the last 24 hours' : 'New experiences this week',
      waiting: 'Waiting for approval',
      quiet: 'New ones with no comment',
      joined: 'People who joined in the period',
      cooling: 'No access for 14 days or more',
      direct: 'Direct messages in the period still unanswered',
      none: 'None',
    };

  return `
    <h2 style="margin:0 0 8px;font-size:18px;">${escapeHtml(groupName)}</h2>
    <p style="margin:0 0 8px;">${escapeHtml(action)}</p>
    ${delta}
    <p style="margin:0;">${labels.people}: <strong>${userIds.length}</strong></p>
    <p style="margin:0;">${labels.active}: <strong>${active}</strong></p>
    <p style="margin:0;">${labels.never}: <strong>${never}</strong></p>
    <p style="margin:0;">${labels.invites}: <strong>${pendingInvites ?? 0}</strong></p>
    <p style="margin:0;">${labels.total}: <strong>${published.length}</strong></p>
    <p style="margin:8px 0 0;">${labels.fresh}: <strong>${publishedNow.length}</strong></p>
    ${list(newTitles, labels.none)}
    <p style="margin:0;">${labels.waiting}: <strong>${pending.length}</strong></p>
    ${list(pendingTitles, labels.none)}
    <p style="margin:0;">${labels.quiet}: <strong>${uncommented.length}</strong></p>
    <p style="margin:0;">${labels.joined}: <strong>${joinedNow}</strong></p>
    <p style="margin:8px 0 0;">${labels.cooling}</p>
    ${list(cooling, labels.none)}
    <p style="margin:0 0 20px;">${labels.direct}: <strong>${unansweredDirect}</strong></p>
    ${top}
  `;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const token = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
    if (token !== serviceKey) return json({ error: 'Not allowed' }, 401);

    const body = await req.json().catch(() => ({}));
    const period: Period = body.period === 'weekly' ? 'weekly' : 'daily';
    const flag = period === 'weekly' ? 'email_weekly_summary' : 'email_daily_summary';
    const bounds = windowFor(period);

    const supabase = createClient(Deno.env.get('SUPABASE_URL')!, serviceKey);
    const { data: settings, error: settingsError } = await supabase
      .from('cc_facilitator_group_settings')
      .select('user_id, group_id')
      .eq(flag, true);
    if (settingsError) throw new Error(settingsError.message);

    const byUser = new Map<string, number[]>();
    for (const row of settings ?? []) {
      const listForUser = byUser.get(row.user_id) ?? [];
      listForUser.push(row.group_id);
      byUser.set(row.user_id, listForUser);
    }

    const mail = await emailConfig(supabase);
    if (!mail.apiKey) throw new Error('Resend API key not configured');

    let sent = 0;
    for (const [userId, groupIds] of byUser) {
      const { data: member } = await supabase
        .from('cc_members')
        .select('email, language, first_name, display_name')
        .eq('auth_user_id', userId)
        .maybeSingle();
      const email = member?.email?.trim();
      if (!email) continue;

      const claimed = await claimLog(supabase, userId, bounds.key);
      if (!claimed) continue;

      const portuguese = prefersPortuguese(member?.language);
      const { data: groups } = await supabase.from('cc_groups').select('id, name').in('id', groupIds);
      const nameById = new Map((groups ?? []).map((group) => [group.id, group.name as string]));

      const sections: string[] = [];
      for (const groupId of groupIds) {
        sections.push(await groupSection(
          supabase,
          groupId,
          nameById.get(groupId) || (portuguese ? 'Grupo' : 'Group'),
          period,
          portuguese,
          bounds,
        ));
      }
      if (sections.length === 0) continue;

      const subject = portuguese
        ? (period === 'daily' ? `Resumo dos seus grupos — ${bounds.day}` : `Resumo semanal dos seus grupos — ${bounds.day}`)
        : (period === 'daily' ? `Your groups summary — ${bounds.day}` : `Weekly summary of your groups — ${bounds.day}`);
      const intro = portuguese
        ? `<p>Olá${firstName(member) ? ` ${escapeHtml(firstName(member))}` : ''},</p>`
        : `<p>Hello${firstName(member) ? ` ${escapeHtml(firstName(member))}` : ''},</p>`;
      await sendEmail({
        apiKey: mail.apiKey,
        from: mail.from,
        to: email,
        subject,
        html: emailShell(subject, intro + sections.join('<hr style="border:none;border-top:1px solid #eee;margin:8px 0 20px;">')),
      });
      sent += 1;
    }

    return json({ success: true, period, sent });
  } catch (error) {
    console.error('facilitator-digest error:', error);
    return json({ error: String(error) }, 500);
  }
});
