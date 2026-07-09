import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const ADMIN_PORTAL_URL = 'https://good-wishes-project.web.app';

const CATEGORY_LABELS: Record<string, string> = {
  journey: 'Journey',
  community: 'Community',
  account: 'Account',
  technical: 'Technical',
  other: 'Other',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // Payload sent by the database trigger (contains the new record)
    const payload = await req.json();
    const record = payload.record ?? payload;

    const requestId: number = record.id;
    const title: string = record.title ?? 'No title';
    const description: string = record.description ?? '';
    const category: string = record.category ?? 'other';
    const requestNumber: string = record.request_number ?? `#${requestId}`;
    const userName: string = record.user_name ?? 'Unknown user';
    const userEmail: string = record.user_email ?? '';
    const createdAt: string = record.created_at ?? new Date().toISOString();

    // Fetch all admin users
    const { data: admins, error: adminsError } = await supabase
      .from('cc_members')
      .select('email, first_name, display_name')
      .contains('user_role', ['admin'])
      .eq('status', 'active')
      .not('email', 'is', null);

    if (adminsError) throw new Error(`Error fetching admins: ${adminsError.message}`);
    if (!admins || admins.length === 0) {
      console.log('No admin users found, skipping email.');
      return new Response(JSON.stringify({ success: true, sent: 0 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Fetch email settings
    const { data: settings } = await supabase
      .from('cc_settings')
      .select('setting_key, value')
      .in('setting_key', ['email_from_address', 'email_from_name', 'resend_api_token'])
      .eq('is_active', true);

    const settingsMap = (settings ?? []).reduce((acc: Record<string, string>, s: { setting_key: string; value: string }) => {
      acc[s.setting_key] = s.value;
      return acc;
    }, {});

    const RESEND_API_KEY = settingsMap.resend_api_token || Deno.env.get('RESEND_API_KEY');
    const EMAIL_FROM_ADDRESS = settingsMap.email_from_address || 'noreply@callofthetime.org';
    const EMAIL_FROM_NAME = settingsMap.email_from_name || 'Good Wishes';

    if (!RESEND_API_KEY) {
      throw new Error('Resend API key not configured');
    }

    const directLink = `${ADMIN_PORTAL_URL}/support/${requestId}`;
    const formattedDate = new Date(createdAt).toLocaleString('en-US', {
      weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
      hour: '2-digit', minute: '2-digit',
    });

    const categoryLabel = CATEGORY_LABELS[category] ?? category;

    const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>New Support Request</title>
</head>
<body style="margin:0;padding:0;background-color:#f5f5f5;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f5f5f5;padding:32px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background-color:#e8734a;padding:28px 32px;">
              <p style="margin:0 0 8px;color:rgba(255,255,255,0.7);font-size:12px;font-weight:600;letter-spacing:0.8px;text-transform:uppercase;">COTT Portal Admin</p>
              <h1 style="margin:0;color:#ffffff;font-size:22px;font-weight:700;">New Help Center Request</h1>
              <p style="margin:6px 0 0;color:rgba(255,255,255,0.85);font-size:14px;">${requestNumber} · ${formattedDate}</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:32px;">

              <!-- Category badge -->
              <p style="margin:0 0 20px;">
                <span style="display:inline-block;background-color:#fef3ee;color:#e8734a;border:1px solid #f5c3a8;border-radius:20px;padding:4px 14px;font-size:13px;font-weight:600;">${categoryLabel}</span>
              </p>

              <!-- Title -->
              <h2 style="margin:0 0 12px;font-size:20px;color:#1a1a1a;font-weight:700;">${title}</h2>

              <!-- Description -->
              <div style="background-color:#f9f9f9;border-left:4px solid #e8734a;border-radius:4px;padding:16px 20px;margin-bottom:24px;">
                <p style="margin:0;color:#333333;font-size:15px;line-height:1.7;white-space:pre-wrap;">${description}</p>
              </div>

              <!-- User info -->
              <table cellpadding="0" cellspacing="0" style="width:100%;background-color:#f0f4ff;border-radius:8px;padding:16px;margin-bottom:28px;">
                <tr>
                  <td style="padding:4px 0;">
                    <span style="font-size:13px;color:#666666;font-weight:600;display:block;margin-bottom:2px;">Submitted by</span>
                    <span style="font-size:15px;color:#1a1a1a;">${userName}${userEmail ? ` &lt;${userEmail}&gt;` : ''}</span>
                  </td>
                </tr>
              </table>

              <!-- CTA Button -->
              <table cellpadding="0" cellspacing="0" style="width:100%;">
                <tr>
                  <td align="center">
                    <a href="${directLink}"
                       style="display:inline-block;background-color:#e8734a;color:#ffffff;text-decoration:none;padding:14px 36px;border-radius:8px;font-size:16px;font-weight:700;letter-spacing:0.3px;">
                      Open in Admin Portal →
                    </a>
                  </td>
                </tr>
              </table>

              <p style="margin:24px 0 0;text-align:center;font-size:12px;color:#999999;">
                Or copy this link: <a href="${directLink}" style="color:#e8734a;">${directLink}</a>
              </p>

            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#f5f5f5;padding:20px 32px;text-align:center;">
              <p style="margin:0;font-size:12px;color:#999999;">COTT Portal Admin · Automated notification</p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;

    // Send to all admins
    const adminEmails = admins.map((a: { email: string }) => a.email).filter(Boolean);

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: `${EMAIL_FROM_NAME} <${EMAIL_FROM_ADDRESS}>`,
        to: adminEmails,
        subject: `[Help Center] ${requestNumber}: ${title}`,
        html,
      }),
    });

    if (!res.ok) {
      const errText = await res.text();
      throw new Error(`Resend API error: ${res.status} ${errText}`);
    }

    const resData = await res.json();
    console.log('Email sent to admins:', adminEmails, 'Resend response:', JSON.stringify(resData));

    return new Response(
      JSON.stringify({ success: true, sent: adminEmails.length, email_ids: resData }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    console.error('notify-new-support-request error:', e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
