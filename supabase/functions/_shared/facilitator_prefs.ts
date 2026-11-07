import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

export type FacilitatorPrefs = {
  notify_new_experiences: boolean;
  notify_messages: boolean;
  email_each_experience: boolean;
  email_member_message: boolean;
  email_daily_summary: boolean;
  email_weekly_summary: boolean;
};

export const DEFAULT_PREFS: FacilitatorPrefs = {
  notify_new_experiences: true,
  notify_messages: true,
  email_each_experience: false,
  email_member_message: true,
  email_daily_summary: false,
  email_weekly_summary: false,
};

export function isFacilitatorRole(role: string | null | undefined): boolean {
  if (!role) return false;
  const normalized = role.toUpperCase().replace(/ /g, '_');
  return normalized === 'GROUP_MANAGER' ||
    normalized === 'GROUPMANAGER' ||
    normalized === 'MANAGER';
}

export function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

export function prefersPortuguese(language: string | null | undefined): boolean {
  if (!language) return true;
  return language.toLowerCase().startsWith('pt');
}

export function firstName(row: {
  display_name?: string | null;
  first_name?: string | null;
} | null): string {
  const display = row?.display_name?.trim();
  if (display) return display.split(' ')[0];
  const first = row?.first_name?.trim();
  return first || '';
}

export async function loadPrefs(
  supabase: SupabaseClient,
  userId: string,
  groupId: number,
): Promise<FacilitatorPrefs> {
  const { data } = await supabase
    .from('cc_facilitator_group_settings')
    .select('notify_new_experiences, notify_messages, email_each_experience, email_member_message, email_daily_summary, email_weekly_summary')
    .eq('user_id', userId)
    .eq('group_id', groupId)
    .maybeSingle();
  if (!data) return { ...DEFAULT_PREFS };
  return {
    notify_new_experiences: data.notify_new_experiences ?? DEFAULT_PREFS.notify_new_experiences,
    notify_messages: data.notify_messages ?? DEFAULT_PREFS.notify_messages,
    email_each_experience: data.email_each_experience ?? DEFAULT_PREFS.email_each_experience,
    email_member_message: data.email_member_message ?? DEFAULT_PREFS.email_member_message,
    email_daily_summary: data.email_daily_summary ?? DEFAULT_PREFS.email_daily_summary,
    email_weekly_summary: data.email_weekly_summary ?? DEFAULT_PREFS.email_weekly_summary,
  };
}

/** True when this send is the first one for the key. A repeat is a no-op. */
export async function claimLog(
  supabase: SupabaseClient,
  userId: string,
  dedupeKey: string,
): Promise<boolean> {
  const { error } = await supabase.from('cc_facilitator_notify_log').insert({
    user_id: userId,
    dedupe_key: dedupeKey,
  });
  if (!error) return true;
  if (error.code === '23505') return false;
  throw new Error(error.message);
}

export async function emailConfig(supabase: SupabaseClient): Promise<{
  apiKey: string;
  from: string;
}> {
  const { data: settings } = await supabase
    .from('cc_settings')
    .select('setting_key, value')
    .in('setting_key', ['email_from_address', 'email_from_name', 'resend_api_token'])
    .eq('is_active', true);

  const map = (settings ?? []).reduce((acc: Record<string, string>, row: { setting_key: string; value: string }) => {
    acc[row.setting_key] = row.value;
    return acc;
  }, {});

  const apiKey = map.resend_api_token || Deno.env.get('RESEND_API_KEY') || '';
  const address = map.email_from_address || 'noreply@callofthetime.org';
  const name = map.email_from_name || 'Good Wishes';
  return { apiKey, from: `${name} <${address}>` };
}

export async function sendEmail(options: {
  apiKey: string;
  from: string;
  to: string;
  subject: string;
  html: string;
}): Promise<void> {
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${options.apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: options.from,
      to: [options.to],
      subject: options.subject,
      html: options.html,
    }),
  });
  if (!res.ok) {
    throw new Error(`Resend failed: ${await res.text()}`);
  }
}

export function emailShell(title: string, bodyHtml: string): string {
  return `<!DOCTYPE html>
<html lang="pt">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;background:#f5f5f5;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:32px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;">
        <tr><td style="background:#e8734a;padding:24px 32px;">
          <p style="margin:0;color:#ffffff;font-size:13px;letter-spacing:0.6px;">GOOD WISHES</p>
          <h1 style="margin:8px 0 0;color:#ffffff;font-size:22px;">${escapeHtml(title)}</h1>
        </td></tr>
        <tr><td style="padding:28px 32px;color:#1a1a1a;font-size:15px;line-height:1.5;">
          ${bodyHtml}
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`;
}
