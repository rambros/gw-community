-- Fix cc_view_notifications_users to use cc_members instead of cc_users
-- This fixes user names in notifications

DROP VIEW IF EXISTS public.cc_view_notifications_users;

CREATE VIEW public.cc_view_notifications_users
WITH (security_invoker=on) AS
SELECT
  cc_sharings.id,
  cc_sharings.created_at,
  cc_sharings.updated_at,
  cc_sharings.title,
  cc_sharings.text,
  cc_sharings.privacy,
  cc_sharings.user_id,
  cc_sharings.group_id,
  cc_sharings.visibility,
  cc_sharings.type,
  cc_sharings.locked,

  -- full_name: Respects hide_last_name, with fallback
  COALESCE(
    CASE
      WHEN cc_members.hide_last_name = true OR cc_members.last_name IS NULL OR TRIM(cc_members.last_name) = ''
      THEN TRIM(COALESCE(cc_members.first_name, ''))
      ELSE TRIM(CONCAT(COALESCE(cc_members.first_name, ''), ' ', COALESCE(cc_members.last_name, '')))
    END,
    NULLIF(TRIM(cc_members.display_name), ''),
    'Anonymous User'
  ) AS full_name,

  -- display_name: Uses saved display_name, with fallback
  COALESCE(
    NULLIF(TRIM(cc_members.display_name), ''),
    NULLIF(TRIM(cc_members.first_name), ''),
    'User'
  ) AS display_name,

  cc_members.photo_url

FROM cc_sharings
LEFT JOIN cc_members ON cc_sharings.user_id = cc_members.auth_user_id
WHERE cc_sharings.type = 'notification';
