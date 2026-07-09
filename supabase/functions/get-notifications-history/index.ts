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

    // For push_notification logs, we only saved one record per send (the admin's user_id).
    // For in_app/both sends, each recipient has their own row — we deduplicate by
    // returning only one row per (title, message, created_at minute) to avoid flooding
    // the history with one row per user. We achieve this by selecting distinct campaigns
    // via a group-by RPC, or simply filtering only the admin's own push_notification logs
    // plus one representative row per announcement type.
    //
    // Simple approach: return unique notifications by grouping on (type, title, created_at truncated to minute).
    // Supabase doesn't support DISTINCT ON via the JS client, so we use raw SQL via rpc.

    let query = supabase
      .from('cc_notifications')
      .select('id, type, title, message, group_id, reference_type, reference_id, metadata, created_at, user_id')
      .order('created_at', { ascending: false });

    if (type) query = query.eq('type', type);
    if (startDate) query = query.gte('created_at', startDate);
    if (endDate) {
      const end = new Date(endDate);
      end.setDate(end.getDate() + 1);
      query = query.lt('created_at', end.toISOString());
    }

    // For announcement types, each send creates one row per user — fetch only distinct
    // campaigns by picking the latest id per (type+title+truncated_minute).
    // We use a raw SQL RPC for that. If unavailable, fall back to fetching and deduping in JS.
    const announcementTypes = ['admin_announcement', 'group_announcement'];

    let results: Record<string, unknown>[] = [];

    if (!type || !announcementTypes.includes(type)) {
      // push_notification (one row per send) — fetch directly
      const pushQuery = supabase
        .from('cc_notifications')
        .select('id, type, title, message, group_id, reference_type, reference_id, metadata, created_at, user_id')
        .eq('type', 'push_notification')
        .order('created_at', { ascending: false });

      if (startDate) pushQuery.gte('created_at', startDate);
      if (endDate) {
        const end = new Date(endDate!);
        end.setDate(end.getDate() + 1);
        pushQuery.lt('created_at', end.toISOString());
      }
      if (search) {
        pushQuery.or(`title.ilike.%${search}%,message.ilike.%${search}%`);
      }

      const { data: pushData, error: pushErr } = await pushQuery.range(offset, offset + limit - 1);
      if (pushErr) throw pushErr;
      results = [...(pushData ?? [])];
    }

    if (!type || announcementTypes.includes(type)) {
      // For announcements: deduplicate by fetching all and keeping first occurrence per (type+title+minute)
      const annQuery = supabase
        .from('cc_notifications')
        .select('id, type, title, message, group_id, reference_type, reference_id, metadata, created_at, user_id')
        .in('type', type ? [type] : announcementTypes)
        .order('created_at', { ascending: false })
        .limit(5000); // fetch a larger set to deduplicate

      if (startDate) annQuery.gte('created_at', startDate);
      if (endDate) {
        const end = new Date(endDate!);
        end.setDate(end.getDate() + 1);
        annQuery.lt('created_at', end.toISOString());
      }
      if (search) {
        annQuery.or(`title.ilike.%${search}%,message.ilike.%${search}%`);
      }

      const { data: annData, error: annErr } = await annQuery;
      if (annErr) throw annErr;

      // Deduplicate: keep first (most-recent id) per (type + title + minute)
      const seen = new Set<string>();
      const deduped: Record<string, unknown>[] = [];
      for (const row of (annData ?? [])) {
        const minute = (row.created_at as string).substring(0, 16); // "YYYY-MM-DDTHH:MM"
        const key = `${row.type}|${row.title}|${minute}`;
        if (!seen.has(key)) {
          seen.add(key);
          deduped.push(row);
        }
      }
      results = [...results, ...deduped];
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
