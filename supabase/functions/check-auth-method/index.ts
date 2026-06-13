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
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    const body = await req.json();
    const { email } = body as { email: string };
    if (!email) {
      return json({ error: 'email is required' }, 400);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // Find member by invite email (always the canonical email)
    const { data: member } = await adminClient
      .from('cc_members')
      .select('auth_user_id')
      .eq('email', email.toLowerCase().trim())
      .maybeSingle();

    if (!member?.auth_user_id) {
      // Unknown email — let reset proceed (don't reveal if email exists)
      return json({ method: 'email' });
    }

    // Get auth user to inspect identities
    const { data: { user } } = await adminClient.auth.admin.getUserById(member.auth_user_id);

    if (!user) {
      return json({ method: 'email' });
    }

    const identities = user.identities ?? [];
    const providers = identities.map((i) => i.provider);

    // If no email identity exists, user is OAuth-only (Apple or Google)
    if (!providers.includes('email') && providers.length > 0) {
      return json({ method: providers[0] }); // 'apple' or 'google'
    }

    return json({ method: 'email' });
  } catch (err) {
    console.error('Unexpected error:', err);
    // Fail open — let reset proceed on unexpected errors
    return json({ method: 'email' });
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
