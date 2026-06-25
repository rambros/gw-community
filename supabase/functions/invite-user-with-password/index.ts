// supabase/functions/invite-user-with-password/index.ts
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

    const { email, first_name, last_name, phone, password, message, group_id } =
      await req.json();

    if (!email) throw new Error("Email is required");
    if (!password) throw new Error("Password is required");
    if (password.length < 7) throw new Error("Password must be at least 7 characters");
    if (!first_name) throw new Error("First name is required");

    // 1. Create or update auth user
    const { data: existingUsersData } = await supabaseClient.auth.admin.listUsers({
      perPage: 1000,
    });
    const existingAuthUser = existingUsersData?.users?.find(
      (u: any) => u.email === email,
    );

    let authUserId: string;

    if (existingAuthUser) {
      const { data: updated, error: updateError } =
        await supabaseClient.auth.admin.updateUserById(existingAuthUser.id, {
          password,
          email_confirm: true,
        });
      if (updateError) throw updateError;
      authUserId = updated.user.id;
      console.log(`Updated password for existing user: ${email}`);
    } else {
      const { data: created, error: authError } =
        await supabaseClient.auth.admin.createUser({
          email,
          password,
          email_confirm: true,
          user_metadata: { first_name, last_name },
        });
      if (authError) throw authError;
      authUserId = created.user.id;
      console.log(`Created new auth user: ${email}`);
    }

    // 2. Create cc_members record if not exists
    const { data: existingMember } = await supabaseClient
      .from("cc_members")
      .select("id")
      .eq("auth_user_id", authUserId)
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
      console.log(`Member record already exists for: ${email} — skipping`);
    }

    // 3. Add to group if group_id provided
    if (group_id) {
      const { data: existingGroupMember } = await supabaseClient
        .from("cc_group_members")
        .select("id")
        .eq("user_id", authUserId)
        .eq("group_id", group_id)
        .maybeSingle();

      if (!existingGroupMember) {
        const { error: groupMemberError } = await supabaseClient
          .from("cc_group_members")
          .insert({ user_id: authUserId, group_id, user_role: "MEMBER" });

        if (groupMemberError) {
          console.error(`Failed to add user to group: ${groupMemberError.message}`);
        } else {
          const { count } = await supabaseClient
            .from("cc_group_members")
            .select("*", { count: "exact", head: true })
            .eq("group_id", group_id);
          await supabaseClient
            .from("cc_groups")
            .update({ number_members: count ?? 0 })
            .eq("id", group_id);
          console.log(`Added ${email} to group ${group_id}`);
        }
      }
    }

    // 4. Read email settings
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

    // 5. Build email HTML
    if (!RESEND_API_KEY) {
      throw new Error(
        "Server configuration error: Missing email provider key",
      );
    }

    const downloadButtonHtml = `<p style="text-align:center;margin:24px 0;">
  <a href="${DOWNLOAD_LINK}" style="display:inline-block;padding:12px 28px;background-color:#340964;color:white;text-decoration:none;border-radius:8px;font-weight:600;font-size:15px;">
    Open / Download the App
  </a>
</p>`;

    let emailContent = message;
    if (!emailContent) {
      emailContent = `
<p>Dear ${first_name},</p>
<p>Welcome to the <strong>Good Wishes App</strong>!</p>
<p>Your account has been created. Use the credentials below to log in:</p>
<p><strong>Email:</strong> ${email}<br><strong>Password:</strong> ${password}</p>
${downloadButtonHtml}
<p>Best regards,<br>${EMAIL_FROM_NAME}</p>`;
    } else {
      // Replace {{link}} with the styled download button
      if (emailContent.includes("{{link}}")) {
        emailContent = emailContent.replace("{{link}}", downloadButtonHtml);
      } else {
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
        subject: "Welcome to Good Wishes App — Your Account is Ready",
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
