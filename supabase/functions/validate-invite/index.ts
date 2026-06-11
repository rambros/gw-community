// supabase/functions/validate-invite/index.ts
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

    const { token } = await req.json();

    if (!token) {
      return new Response(
        JSON.stringify({ valid: false, message: "Token is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Query invitation
    const { data: invitation, error } = await supabaseClient
      .from("invitations")
      .select("*")
      .eq("token", token)
      .eq("status", "pending")
      .maybeSingle();

    if (error) {
      console.error("Database error:", error);
      return new Response(
        JSON.stringify({ valid: false, message: "Error validating invitation" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (!invitation) {
      return new Response(
        JSON.stringify({ valid: false, message: "This invitation link is invalid or has already been used." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Check if expired
    const expiresAt = new Date(invitation.expires_at);
    if (expiresAt < new Date()) {
      // Update status to expired
      await supabaseClient
        .from("invitations")
        .update({ status: "expired" })
        .eq("token", token);

      return new Response(
        JSON.stringify({ valid: false, message: "This invitation link has expired." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Token is valid
    return new Response(
      JSON.stringify({ valid: true, email: invitation.email }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );

  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ valid: false, message: "An unexpected error occurred" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
