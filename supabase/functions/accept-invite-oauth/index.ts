import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return json({ error: 'No authorization header' }, 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;

    // Verify the caller's JWT and get their user ID
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) {
      return json({ error: 'Unauthorized' }, 401);
    }

    const body = await req.json();
    const { token } = body as { token: string };
    if (!token) {
      return json({ error: 'token is required' }, 400);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // Find the cc_members record for this invite token
    const { data: member, error: memberError } = await adminClient
      .from('cc_members')
      .select('id, auth_user_id, status')
      .eq('invite_token', token)
      .maybeSingle();

    if (memberError || !member) {
      return json({ error: 'Invalid or expired invitation' }, 400);
    }

    // Guard: token already consumed by a *different* user
    if (member.auth_user_id && member.auth_user_id !== user.id) {
      return json({ error: 'This invitation has already been used' }, 400);
    }

    // Link the OAuth user, activate the account, and consume the token (one-time use)
    const { error: updateError } = await adminClient
      .from('cc_members')
      .update({
        auth_user_id: user.id,
        status: 'active',
        invite_token: null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', member.id);

    if (updateError) {
      console.error('Failed to update cc_members:', updateError);
      return json({ error: 'Failed to link account' }, 500);
    }

    return json({ success: true });
  } catch (err) {
    console.error('Unexpected error:', err);
    return json({ error: (err as Error).message }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
