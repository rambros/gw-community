// supabase/functions/invite-user/index.ts
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

    const { email, first_name, last_name, role, phone, country, message, group_id } = await req.json();

    if (!email) {
      throw new Error("Email is required");
    }

    // Generate token
    const token = crypto.randomUUID();

    // Upsert invitation — insert or update on email conflict (handles new invites and resends)
    const { error: upsertError } = await supabaseClient
      .from("invitations")
      .upsert(
        {
          email,
          token,
          role: role || 'member',
          group_id: group_id || null,
          metadata: { first_name, last_name, phone, country },
          status: 'pending',
          expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        },
        { onConflict: 'email' }
      );

    if (upsertError) throw upsertError;

    // Get email settings from cc_settings table
    const { data: settings } = await supabaseClient
      .from("cc_settings")
      .select("setting_key, value")
      .in("setting_key", ["email_from_address", "email_from_name", "resend_api_token", "email_invite_link"])
      .eq("is_active", true);

    const settingsMap = settings?.reduce((acc: any, s: any) => {
      acc[s.setting_key] = s.value;
      return acc;
    }, {}) || {};

    const RESEND_API_KEY = settingsMap.resend_api_token || Deno.env.get("RESEND_API_KEY");
    const EMAIL_FROM_ADDRESS = settingsMap.email_from_address || "noreply@callofthetime.org";
    const EMAIL_FROM_NAME = settingsMap.email_from_name || "Good Wishes";
    const INVITE_LINK_BASE = settingsMap.email_invite_link || "https://gw.callofthetime.org/invite";

    // Send Email
    if (RESEND_API_KEY) {
        console.log("Preparing to send email to:", email);
        const inviteLink = `${INVITE_LINK_BASE}?token=${token}`;

        // Get user's first name for personalization
        const firstName = first_name || "there";

        // Default message if not provided
        let emailContent = message;
        if (!emailContent) {
           emailContent = `
               <p>Dear ${firstName},</p>
               <p>You're invited to join the <strong>Good Wishes App</strong>!</p>
               <p>Please click the link below to accept your invitation and set your password:</p>
               <p><a href="${inviteLink}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 6px; font-weight: 500;">Accept Invitation</a></p>
               <p>Or copy and paste this link into your browser:</p>
               <p style="color: #6B7280; font-size: 14px;">${inviteLink}</p>
               <p>This invitation will expire in 7 days.</p>
               <p>Best regards,<br>${EMAIL_FROM_NAME}</p>
           `;
        } else {
           if (emailContent.includes("{{link}}")) {
               emailContent = emailContent.replace("{{link}}", inviteLink);
           } else {
               // Append it if not present
               emailContent += `<br><br><a href="${inviteLink}">Accept Invitation</a>`;
           }
        }

        try {
          const res = await fetch("https://api.resend.com/emails", {
              method: "POST",
              headers: {
                  "Content-Type": "application/json",
                  "Authorization": `Bearer ${RESEND_API_KEY}`
              },
              body: JSON.stringify({
                  from: `${EMAIL_FROM_NAME} <${EMAIL_FROM_ADDRESS}>`,
                  to: [email],
                  subject: "You have been invited to Good Wishes App",
                  html: emailContent
              })
          });

          if (!res.ok) {
            const errorText = await res.text();
            console.error(`Resend API failed: ${res.status} ${errorText}`);
            throw new Error(`Email provider error: ${errorText}`);
          }

          const data = await res.json();
          console.log("Email sent successfully. ID:", data.id);

        } catch (emailError) {
          console.error("Error creating/sending email request:", emailError);
          throw emailError;
        }
    } else {
      console.error("RESEND_API_KEY is not set in environment variables or cc_settings!");
      // We might not want to fail the whole request if email fails, but for now strict is better for debugging
      throw new Error("Server configuration error: Missing email provider key");
    }

    return new Response(
      JSON.stringify({ success: true, message: "Invitation sent" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
