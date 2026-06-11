// supabase/functions/accept-invite/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const { token, password } = await req.json();

    if (!token || !password) {
      throw new Error("Token and password are required");
    }

    // 1. Validate Token
    const { data: invite, error: inviteError } = await supabaseClient
      .from("invitations")
      .select("*")
      .eq("token", token)
      .eq("status", "pending")
      .single();

    if (inviteError || !invite) {
      throw new Error("Invalid or expired invitation.");
    }

    // Check expiry
    if (new Date(invite.expires_at) < new Date()) {
        await supabaseClient.from("invitations").update({ status: 'expired' }).eq("id", invite.id);
        throw new Error("Invitation has expired.");
    }

    // 2. Create or update Auth User (idempotent — handles resends for existing users)
    const { data: existingUsersData } = await supabaseClient.auth.admin.listUsers({ perPage: 1000 });
    const existingAuthUser = existingUsersData?.users?.find((u: any) => u.email === invite.email);

    let authUserId: string;

    if (existingAuthUser) {
      // User already exists — update password so the new invite works as a password reset
      const { data: updated, error: updateError } = await supabaseClient.auth.admin.updateUserById(
        existingAuthUser.id,
        { password, email_confirm: true }
      );
      if (updateError) throw updateError;
      authUserId = updated.user.id;
      console.log(`Updated password for existing user: ${invite.email}`);
    } else {
      // New user — create auth account
      const { data: created, error: authError } = await supabaseClient.auth.admin.createUser({
        email: invite.email,
        password,
        email_confirm: true,
        user_metadata: invite.metadata,
      });
      if (authError) throw authError;
      authUserId = created.user.id;
      console.log(`Created new auth user: ${invite.email}`);
    }

    // 3. Create Member Record only if it doesn't exist yet
    const { data: existingMember } = await supabaseClient
      .from("cc_members")
      .select("id")
      .eq("auth_user_id", authUserId)
      .maybeSingle();

    if (!existingMember) {
      const metadata = invite.metadata || {};
      const { error: memberError } = await supabaseClient.from("cc_members").insert({
        auth_user_id: authUserId,
        first_name: metadata.first_name,
        last_name: metadata.last_name,
        email: invite.email,
        user_role: invite.role ? [invite.role] : ['member'],
      });
      if (memberError) throw memberError;
      console.log(`Created member record for: ${invite.email}`);
    } else {
      console.log(`Member record already exists for: ${invite.email} — skipping`);
    }

    // 4. Add to group if group_id is set on the invitation
    if (invite.group_id) {
      const { data: existingGroupMember } = await supabaseClient
        .from("cc_group_members")
        .select("id")
        .eq("user_id", authUserId)
        .eq("group_id", invite.group_id)
        .maybeSingle();

      if (!existingGroupMember) {
        const { error: groupMemberError } = await supabaseClient
          .from("cc_group_members")
          .insert({ user_id: authUserId, group_id: invite.group_id, user_role: 'MEMBER' });

        if (groupMemberError) {
          console.error(`Failed to add user to group: ${groupMemberError.message}`);
        } else {
          // Recount members and update the group counter
          const { count } = await supabaseClient
            .from("cc_group_members")
            .select("*", { count: "exact", head: true })
            .eq("group_id", invite.group_id);
          await supabaseClient
            .from("cc_groups")
            .update({ number_members: count ?? 0 })
            .eq("id", invite.group_id);
          console.log(`Added ${invite.email} to group ${invite.group_id}`);
        }
      } else {
        console.log(`User ${invite.email} already in group ${invite.group_id} — skipping`);
      }
    }

    // 5. Mark Invitation as Used
    await supabaseClient.from("invitations").update({ status: 'used' }).eq("id", invite.id);

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
