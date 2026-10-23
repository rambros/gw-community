import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

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
  sharing: { user_id: string | null; recipient_user_id: string | null },
): boolean {
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
      .select('id, type, title, group_id, user_id, recipient_user_id')
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
      .select('user_id')
      .eq('group_id', sharing.group_id);
    if (membersError) throw new Error(membersError.message);

    const recipients = (members ?? [])
      .map((member) => member.user_id)
      .filter((userId): userId is string =>
        typeof userId === 'string' &&
        userId !== sharing.user_id &&
        canSeeMessage(userId, sharing)
      );
    if (recipients.length === 0) {
      return json({ skipped: true, reason: 'no recipients' });
    }

    const { data: group } = await supabase
      .from('cc_groups')
      .select('name')
      .eq('id', sharing.group_id)
      .maybeSingle();

    const pushRes = await fetch(`${supabaseUrl}/functions/v1/send-push-notification`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${serviceKey}`,
        apikey: serviceKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        user_ids: recipients,
        title: group?.name ?? 'New message',
        message: String(sharing.title ?? 'New message').slice(0, 120),
        channel: 'push',
        group_id: sharing.group_id,
        reference_type: 'group_message',
        reference_id: sharing.id,
      }),
    });

    if (!pushRes.ok) {
      console.error('send-push-notification failed:', await pushRes.text());
      return json({ error: 'Push failed' }, 502);
    }

    return json({ success: true, pushed: recipients.length });
  } catch (error) {
    console.error('notify-group-message error:', error);
    return json({ error: String(error) }, 500);
  }
});
