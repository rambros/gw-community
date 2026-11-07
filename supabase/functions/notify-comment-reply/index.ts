import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { isFacilitatorRole, loadPrefs } from '../_shared/facilitator_prefs.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const PUSH_WINDOW_MS = 15 * 60 * 1000;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function canSeeMessage(
  memberId: string,
  isFacilitator: boolean,
  sharing: { user_id: string | null; recipient_user_id: string | null; audience?: string | null },
): boolean {
  if (sharing.audience === 'facilitators') {
    return isFacilitator || sharing.user_id === memberId;
  }
  if (sharing.recipient_user_id == null) return true;
  return sharing.recipient_user_id === memberId || sharing.user_id === memberId;
}

async function shouldPush(
  supabase: SupabaseClient,
  sharingId: number,
  userId: string,
): Promise<boolean> {
  const { data: readRow } = await supabase
    .from('cc_sharing_reads')
    .select('read_at')
    .eq('sharing_id', sharingId)
    .eq('user_id', userId)
    .maybeSingle();

  const { data: alertRow } = await supabase
    .from('cc_comment_reply_alerts')
    .select('last_pushed_at')
    .eq('sharing_id', sharingId)
    .eq('user_id', userId)
    .maybeSingle();

  const readAt = readRow?.read_at ? new Date(readRow.read_at) : null;
  const lastPushed = alertRow?.last_pushed_at ? new Date(alertRow.last_pushed_at) : null;
  if (lastPushed == null) return true;
  const stillUnread = readAt == null || lastPushed > readAt;
  const withinWindow = Date.now() - lastPushed.getTime() < PUSH_WINDOW_MS;
  return !(stillUnread && withinWindow);
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
    const commentId = Number(body.comment_id);
    if (!Number.isFinite(commentId)) return json({ error: 'comment_id required' }, 400);

    const supabase = createClient(supabaseUrl, serviceKey);
    const { data: comment, error: commentError } = await supabase
      .from('cc_comments')
      .select('id, user_id, sharing_id, parent_id')
      .eq('id', commentId)
      .maybeSingle();
    if (commentError) throw new Error(commentError.message);
    if (!comment) return json({ error: 'Comment not found' }, 404);
    if (comment.user_id !== userData.user.id) {
      return json({ error: 'Not the comment author' }, 403);
    }

    const { data: sharing, error: sharingError } = await supabase
      .from('cc_sharings')
      .select('id, type, title, group_id, user_id, recipient_user_id, audience')
      .eq('id', comment.sharing_id)
      .maybeSingle();
    if (sharingError) throw new Error(sharingError.message);
    if (!sharing || sharing.type !== 'notification' || sharing.group_id == null) {
      return json({ skipped: true });
    }

    const { data: members, error: membersError } = await supabase
      .from('cc_group_members')
      .select('user_id, user_role')
      .eq('group_id', sharing.group_id);
    if (membersError) throw new Error(membersError.message);

    const recipientIds = new Set<string>();
    for (const member of members ?? []) {
      if (typeof member.user_id !== 'string') continue;
      if (member.user_id === comment.user_id) continue;
      if (!isFacilitatorRole(member.user_role)) continue;
      if (!canSeeMessage(member.user_id, true, sharing)) continue;
      const prefs = await loadPrefs(supabase, member.user_id, sharing.group_id);
      if (!prefs.notify_messages) continue;
      recipientIds.add(member.user_id);
    }

    // The person who wrote the message, and a private recipient, hear the first
    // reply even when that reply is not attached to one of their comments.
    for (const userId of [sharing.user_id, sharing.recipient_user_id]) {
      if (typeof userId !== 'string' || userId === comment.user_id) continue;
      const member = (members ?? []).find((row) => row.user_id === userId);
      const facilitator = isFacilitatorRole(member?.user_role);
      if (!canSeeMessage(userId, facilitator, sharing)) continue;
      if (facilitator) {
        const prefs = await loadPrefs(supabase, userId, sharing.group_id);
        if (!prefs.notify_messages) continue;
      }
      recipientIds.add(userId);
    }

    // A reply also goes to the person who was answered. Walking up covers a
    // facilitator answering a member, including a reply to that answer.
    let parentId = comment.parent_id as number | null;
    const seenParents = new Set<number>();
    while (parentId != null && !seenParents.has(parentId)) {
      seenParents.add(parentId);
      const { data: parent, error: parentError } = await supabase
        .from('cc_comments')
        .select('id, user_id, parent_id')
        .eq('id', parentId)
        .maybeSingle();
      if (parentError) throw new Error(parentError.message);
      if (!parent) break;
      if (typeof parent.user_id === 'string' && parent.user_id !== comment.user_id) {
        const parentMember = (members ?? []).find((row) => row.user_id === parent.user_id);
        const parentIsFacilitator = isFacilitatorRole(parentMember?.user_role);
        const visible = canSeeMessage(parent.user_id, parentIsFacilitator, sharing);
        if (visible) {
          const prefs = parentIsFacilitator
            ? await loadPrefs(supabase, parent.user_id, sharing.group_id)
            : null;
          if (!parentIsFacilitator || prefs?.notify_messages) {
            recipientIds.add(parent.user_id);
          }
        }
      }
      parentId = parent.parent_id as number | null;
    }

    if (recipientIds.size === 0) {
      return json({ skipped: true, reason: 'no recipients' });
    }

    const { data: author } = await supabase
      .from('cc_members')
      .select('display_name, first_name, last_name')
      .eq('auth_user_id', comment.user_id)
      .maybeSingle();
    const authorName = (
      author?.display_name ||
      [author?.first_name, author?.last_name].filter(Boolean).join(' ') ||
      'Someone'
    ).trim();

    const { data: group } = await supabase
      .from('cc_groups')
      .select('name')
      .eq('id', sharing.group_id)
      .maybeSingle();

    const messageTitle = String(sharing.title ?? 'a message').slice(0, 80);
    const outcomes = await Promise.all([...recipientIds].map(async (userId) => {
      if (!await shouldPush(supabase, sharing.id, userId)) return false;

      let countQuery = supabase
        .from('cc_comments')
        .select('id', { count: 'exact', head: true })
        .eq('sharing_id', sharing.id)
        .neq('user_id', userId);
      const { data: readRow } = await supabase
        .from('cc_sharing_reads')
        .select('read_at')
        .eq('sharing_id', sharing.id)
        .eq('user_id', userId)
        .maybeSingle();
      if (readRow?.read_at) {
        countQuery = countQuery.gt('created_at', readRow.read_at);
      }
      const { count } = await countQuery;
      const replyCount = count && count > 0 ? count : 1;
      const recipient = (members ?? []).find((member) => member.user_id === userId);
      const recipientIsFacilitator = isFacilitatorRole(recipient?.user_role ?? null);
      const body = recipientIsFacilitator && replyCount > 1
        ? `${replyCount} new replies on "${messageTitle}"`
        : `${authorName} replied to "${messageTitle}"`;

      const pushRes = await fetch(`${supabaseUrl}/functions/v1/send-push-notification`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${serviceKey}`,
          apikey: serviceKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          user_ids: [userId],
          title: group?.name ?? 'New replies',
          message: body,
          channel: 'push',
          group_id: sharing.group_id,
          reference_type: 'group_message',
          reference_id: sharing.id,
        }),
      });

      if (!pushRes.ok) {
        console.error('send-push-notification failed:', await pushRes.text());
        return false;
      }

      const { error: alertError } = await supabase.from('cc_comment_reply_alerts').upsert({
        user_id: userId,
        sharing_id: sharing.id,
        last_pushed_at: new Date().toISOString(),
      }, { onConflict: 'user_id,sharing_id' });
      if (alertError) {
        console.error('alert upsert failed:', alertError.message);
      }
      return true;
    }));

    return json({ success: true, pushed: outcomes.filter(Boolean).length });
  } catch (error) {
    console.error('notify-comment-reply error:', error);
    return json({ error: String(error) }, 500);
  }
});
