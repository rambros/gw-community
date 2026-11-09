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

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) return json({ error: 'Unauthorized' }, 401);

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) return json({ error: 'Unauthorized' }, 401);

    const admin = createClient(supabaseUrl, serviceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const userId = user.id;
    const { data: member } = await admin
      .from('cc_members')
      .select('id')
      .eq('auth_user_id', userId)
      .maybeSingle();

    const clearAuthRef = async (table: string, column: string) => {
      const { error } = await admin.from(table).update({ [column]: null }).eq(column, userId);
      if (error) throw new Error(`${table}.${column}: ${error.message}`);
    };

    await clearAuthRef('cc_sharings', 'recipient_user_id');
    const { error: chatError } = await admin.from('cc_chat_messages').delete().eq('user_id', userId);
    if (chatError) throw new Error(`cc_chat_messages: ${chatError.message}`);
    await clearAuthRef('cc_support_requests', 'assigned_to');
    await clearAuthRef('cc_distribution_lists', 'created_by');
    await clearAuthRef('cc_list_members', 'added_by');
    await clearAuthRef('cc_email_templates', 'created_by');
    await clearAuthRef('cc_email_campaigns', 'sent_by');
    await clearAuthRef('cc_settings', 'created_by');
    await clearAuthRef('cc_settings', 'updated_by');
    await clearAuthRef('invitations', 'created_by');
    await clearAuthRef('cc_group_journeys', 'added_by');
    await clearAuthRef('cc_group_resources', 'added_by');

    if (member?.id) {
      const { error: logsError } = await admin
        .from('cc_email_sending_logs')
        .delete()
        .eq('member_id', member.id);
      if (logsError) throw new Error(`cc_email_sending_logs: ${logsError.message}`);

      const { error: memberError } = await admin.from('cc_members').delete().eq('id', member.id);
      if (memberError) throw new Error(`cc_members: ${memberError.message}`);
    }

    const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
    if (deleteError) throw new Error(deleteError.message);

    return json({ message: 'Account deleted' });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Internal server error';
    console.error('delete-own-account:', message);
    return json({ error: message }, 500);
  }
});
