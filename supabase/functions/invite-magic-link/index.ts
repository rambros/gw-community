// supabase/functions/invite-magic-link/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const MAGIC_LINK_REDIRECT_URL =
  Deno.env.get("MAGIC_LINK_REDIRECT_URL") ??
  "https://gw-invite.web.app/login-callback";

function resolveGroupIds(group_id: unknown, group_ids: unknown): number[] {
  const ids = new Set<number>();

  if (Array.isArray(group_ids)) {
    for (const id of group_ids) {
      const parsed = typeof id === "number" ? id : parseInt(String(id), 10);
      if (!Number.isNaN(parsed)) ids.add(parsed);
    }
  }

  if (group_id != null) {
    const parsed = typeof group_id === "number"
      ? group_id
      : parseInt(String(group_id), 10);
    if (!Number.isNaN(parsed)) ids.add(parsed);
  }

  return [...ids];
}

async function addUserToGroup(
  supabaseClient: ReturnType<typeof createClient>,
  authUserId: string,
  email: string,
  groupId: number,
) {
  const { data: existingGroupMember } = await supabaseClient
    .from("cc_group_members")
    .select("id")
    .eq("user_id", authUserId)
    .eq("group_id", groupId)
    .maybeSingle();

  if (existingGroupMember) {
    console.log(`User ${email} already in group ${groupId} — skipping`);
    return;
  }

  const { error: groupMemberError } = await supabaseClient
    .from("cc_group_members")
    .insert({ user_id: authUserId, group_id: groupId, user_role: "MEMBER" });

  if (groupMemberError) {
    console.error(`Failed to add user to group ${groupId}: ${groupMemberError.message}`);
    return;
  }

  const { count } = await supabaseClient
    .from("cc_group_members")
    .select("*", { count: "exact", head: true })
    .eq("group_id", groupId);

  await supabaseClient
    .from("cc_groups")
    .update({ number_members: count ?? 0 })
    .eq("id", groupId);

  console.log(`Added ${email} to group ${groupId}`);
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const { email, first_name, last_name, phone, message, group_id, group_ids } =
      await req.json();

    if (!email) throw new Error("Email is required");
    if (!first_name) throw new Error("First name is required");

    const groupIds = resolveGroupIds(group_id, group_ids);

    // 1. Check if auth user already exists for this email
    const { data: existingUsersData } = await supabaseClient.auth.admin.listUsers({
      perPage: 1000,
    });
    const existingAuthUser = existingUsersData?.users?.find(
      (u: any) => u.email === email,
    );

    let authUserId: string;

    if (existingAuthUser) {
      authUserId = existingAuthUser.id;
      console.log(`Auth user already exists for: ${email}`);
    } else {
      const { data: created, error: authError } =
        await supabaseClient.auth.admin.createUser({
          email,
          email_confirm: true,
          user_metadata: { first_name, last_name },
        });
      if (authError) throw authError;
      authUserId = created.user.id;
      console.log(`Created new auth user (passwordless): ${email}`);
    }

    // 2. Create cc_members record if not exists
    const { data: existingMember } = await supabaseClient
      .from("cc_members")
      .select("id")
      .eq("email", email)
      .maybeSingle();

    if (!existingMember) {
      const { error: memberError } = await supabaseClient
        .from("cc_members")
        .insert({
          auth_user_id: authUserId,
          first_name,
          last_name,
          email,
          phone,
          user_role: ["member"],
        });
      if (memberError) throw memberError;
      console.log(`Created member record for: ${email}`);
    } else {
      const { error: updateError } = await supabaseClient
        .from("cc_members")
        .update({ auth_user_id: authUserId })
        .eq("email", email)
        .is("auth_user_id", null);
      if (updateError) {
        console.error(`Failed to link auth_user_id: ${updateError.message}`);
      }
      console.log(`Member record already exists for: ${email} — skipping`);
    }

    // 3. Add to selected groups
    for (const gid of groupIds) {
      await addUserToGroup(supabaseClient, authUserId, email, gid);
    }

    // 4. Generate Supabase magic link (redirects through HTTPS landing page)
    const { data: linkData, error: linkError } =
      await supabaseClient.auth.admin.generateLink({
        type: "magiclink",
        email,
        options: {
          redirectTo: MAGIC_LINK_REDIRECT_URL,
        },
      });

    if (linkError) throw linkError;

    const magicLink = linkData.properties?.action_link;
    if (!magicLink) {
      throw new Error("Failed to generate magic link");
    }

    console.log(
      `Generated magic link for ${email} with redirectTo=${MAGIC_LINK_REDIRECT_URL}`,
    );

    // 5. Read email settings
    const { data: settings } = await supabaseClient
      .from("cc_settings")
      .select("setting_key, value")
      .in("setting_key", [
        "email_from_address",
        "email_from_name",
        "resend_api_token",
        "invite_with_password_link",
      ])
      .eq("is_active", true);

    const settingsMap =
      settings?.reduce((acc: any, s: any) => {
        acc[s.setting_key] = s.value;
        return acc;
      }, {}) || {};

    const RESEND_API_KEY =
      settingsMap.resend_api_token || Deno.env.get("RESEND_API_KEY");
    const EMAIL_FROM_ADDRESS =
      settingsMap.email_from_address || "noreply@callofthetime.org";
    const EMAIL_FROM_NAME = settingsMap.email_from_name || "Good Wishes";
    const DOWNLOAD_LINK =
      settingsMap.invite_with_password_link ||
      "https://gw-invite.web.app/welcome";

    if (!RESEND_API_KEY) {
      throw new Error("Server configuration error: Missing email provider key");
    }

    // 6. Build email content
    const signInButtonHtml = `<p style="text-align:center;margin:24px 0;">
  <a href="${magicLink}" style="display:inline-block;padding:12px 28px;background-color:#340964;color:white;text-decoration:none;border-radius:8px;font-weight:600;font-size:15px;">
    Sign In to Good Wishes
  </a>
</p>`;

    const downloadButtonHtml = `<p style="text-align:center;margin:16px 0;">
  <a href="${DOWNLOAD_LINK}" style="display:inline-block;padding:10px 24px;background-color:#7C52A0;color:white;text-decoration:none;border-radius:8px;font-weight:600;font-size:14px;">
    Open / Download the App
  </a>
</p>`;

    let emailContent = message;
    if (!emailContent) {
      emailContent = `
<p>Dear ${first_name},</p>
<p>Welcome to the <strong>Good Wishes App</strong>!</p>
<p>Your account has been set up with <strong>${email}</strong>.</p>
<p>Click the button below to sign in — no password needed!</p>
${signInButtonHtml}
${downloadButtonHtml}
<p>Best regards,<br>${EMAIL_FROM_NAME}</p>`;
    } else {
      if (emailContent.includes("{{link}}")) {
        emailContent = emailContent.replaceAll("{{link}}", signInButtonHtml);
      } else {
        emailContent += `<br><br>${signInButtonHtml}`;
      }
      if (!emailContent.includes(DOWNLOAD_LINK)) {
        emailContent += `<br><br>${downloadButtonHtml}`;
      }
    }

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: `${EMAIL_FROM_NAME} <${EMAIL_FROM_ADDRESS}>`,
        to: [email],
        subject: "Welcome to Good Wishes App",
        html: emailContent,
      }),
    });

    if (!res.ok) {
      const errorText = await res.text();
      console.error(`Resend API failed: ${res.status} ${errorText}`);
      throw new Error(`Email provider error: ${errorText}`);
    }

    const data = await res.json();
    console.log("Email sent successfully. ID:", data.id);

    return new Response(
      JSON.stringify({ success: true, message: "Member invited successfully" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
