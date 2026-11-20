import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify caller is authenticated
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Use service role to bypass RLS
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // Verify the JWT belongs to a real user
    const userClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Parse params from body
    const body = await req.json().catch(() => ({}));
    const type: string | undefined = body.type;
    const startDate: string | undefined = body.start_date;
    const endDate: string | undefined = body.end_date;
    const search: string | undefined = body.search;
    const offset = parseInt(body.offset ?? '0', 10);
    const limit = parseInt(body.limit ?? '50', 10);

    const channelFilters = new Set(['push', 'in_app', 'both']);
    const campaignTypes = ['admin_announcement', 'group_announcement'];
    const wantsChannel = !!type && channelFilters.has(type);
    const wantsCampaign = !type || wantsChannel || campaignTypes.includes(type);
    const wantsInbox = !!type
      ? !wantsChannel && !campaignTypes.includes(type)
      : true;

    const endOfDay = (day: string) => {
      const end = new Date(day);
      end.setDate(end.getDate() + 1);
      return end.toISOString();
    };

    let results: Record<string, unknown>[] = [];

    if (wantsCampaign) {
      let sendQuery = supabase
        .from('cc_notification_sends')
        .select('id, created_at, created_by, channel, type, title, message, image_url, group_id, target_type, recipient_count, push_sent, push_failed, in_app_sent')
        .order('created_at', { ascending: false })
        .limit(1000);

      if (wantsChannel && type) sendQuery = sendQuery.eq('channel', type);
      else if (type && campaignTypes.includes(type)) sendQuery = sendQuery.eq('type', type);
      if (startDate) sendQuery = sendQuery.gte('created_at', startDate);
      if (endDate) sendQuery = sendQuery.lt('created_at', endOfDay(endDate));
      if (search) sendQuery = sendQuery.or(`title.ilike.%${search}%,message.ilike.%${search}%`);

      const { data: sends, error: sendError } = await sendQuery;
      if (sendError) throw sendError;

      results = (sends ?? []).map((row) => ({
        id: row.id,
        record_kind: 'send',
        type: row.type,
        title: row.title,
        message: row.message,
        user_id: row.created_by ?? '',
        is_read: true,
        group_id: row.group_id,
        reference_type: null,
        reference_id: null,
        created_at: row.created_at,
        metadata: {
          image_url: row.image_url,
          recipient_count: row.recipient_count,
          target_type: row.target_type,
          channel: row.channel,
          in_app_sent: row.in_app_sent,
          push_sent: row.push_sent,
          push_failed: row.push_failed,
          record_kind: 'send',
        },
      }));
    }

    if (wantsInbox) {
      let inboxQuery = supabase
        .from('cc_notifications')
        .select('id, type, title, message, group_id, reference_type, reference_id, metadata, created_at, user_id, is_read')
        .is('send_id', null)
        .not('type', 'in', '("admin_announcement","group_announcement","push_notification")')
        .order('created_at', { ascending: false })
        .limit(1000);

      if (type) inboxQuery = inboxQuery.eq('type', type);
      if (startDate) inboxQuery = inboxQuery.gte('created_at', startDate);
      if (endDate) inboxQuery = inboxQuery.lt('created_at', endOfDay(endDate));
      if (search) inboxQuery = inboxQuery.or(`title.ilike.%${search}%,message.ilike.%${search}%`);

      const { data: inbox, error: inboxError } = await inboxQuery;
      if (inboxError) throw inboxError;
      results = [
        ...results,
        ...(inbox ?? []).map((row) => ({ ...row, record_kind: 'notification' })),
      ];
    }

    // Sort combined results by created_at desc and paginate
    results.sort((a, b) =>
      new Date(b.created_at as string).getTime() - new Date(a.created_at as string).getTime()
    );
    const paginated = results.slice(offset, offset + limit);

    return new Response(
      JSON.stringify({ data: paginated, total: results.length }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    console.error('get-notifications-history error:', e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
