-- Update cc_view_sharings_users to include moderation fields
-- Run this script in Supabase SQL Editor to add moderation_status and moderation_reason

DROP VIEW IF EXISTS public.cc_view_sharings_users;

CREATE VIEW public.cc_view_sharings_users
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

  -- Moderation fields
  cc_sharings.moderation_status,
  cc_sharings.moderation_reason,

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

  cc_members.photo_url,

  -- Group name
  cc_groups.name AS group_name,

  -- Comments count
  (SELECT COUNT(*) FROM cc_comments WHERE cc_comments.sharing_id = cc_sharings.id) AS comments

FROM cc_sharings
LEFT JOIN cc_members ON cc_sharings.user_id = cc_members.auth_user_id
LEFT JOIN cc_groups ON cc_sharings.group_id = cc_groups.id;
