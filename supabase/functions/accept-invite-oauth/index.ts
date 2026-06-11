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

    // Find invitation in the invitations table (email-based admin invite flow)
    const { data: invite, error: inviteError } = await adminClient
      .from('invitations')
      .select('*')
      .eq('token', token)
      .eq('status', 'pending')
      .maybeSingle();

    if (inviteError || !invite) {
      return json({ error: 'Invalid or expired invitation' }, 400);
    }

    // Check expiry
    if (new Date(invite.expires_at) < new Date()) {
      await adminClient.from('invitations').update({ status: 'expired' }).eq('id', invite.id);
      return json({ error: 'Invitation has expired' }, 400);
    }

    // Create cc_members record only if one doesn't exist yet for this auth user
    const { data: existingMember } = await adminClient
      .from('cc_members')
      .select('id')
      .eq('auth_user_id', user.id)
      .maybeSingle();

    if (!existingMember) {
      const metadata = (invite.metadata as Record<string, string>) || {};
      const { error: memberError } = await adminClient.from('cc_members').insert({
        auth_user_id: user.id,
        first_name: metadata.first_name,
        last_name: metadata.last_name,
        email: invite.email,
        user_role: invite.role ? [invite.role] : ['member'],
      });
      if (memberError) {
        console.error('Failed to create member record:', memberError);
        return json({ error: 'Failed to create member record' }, 500);
      }
      console.log(`Created member record for OAuth user: ${invite.email}`);
    } else {
      console.log(`Member record already exists for: ${invite.email} — skipping`);
    }

    // Mark invitation as used (one-time use)
    await adminClient.from('invitations').update({ status: 'used' }).eq('id', invite.id);

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
