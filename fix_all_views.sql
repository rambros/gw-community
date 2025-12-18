-- Fix all views to use cc_members instead of cc_users
-- Run this script in Supabase SQL Editor to fix user names showing as "User"

-- ============================================================
-- 1. Fix cc_view_sharings_users
-- ============================================================

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
LEFT JOIN cc_members ON cc_sharings.user_id = cc_members.auth_user_id;

-- ============================================================
-- 2. Fix cc_view_notifications_users
-- ============================================================

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

-- ============================================================
-- 3. Fix cc_view_ordered_comments
-- ============================================================

DROP VIEW IF EXISTS public.cc_view_ordered_comments;

CREATE VIEW public.cc_view_ordered_comments
WITH (security_invoker=on) AS
WITH RECURSIVE comment_tree AS (
  -- Base case: root comments (no parent)
  SELECT
    cc_comments.id,
    cc_comments.parent_id,
    cc_comments.id AS root_id,
    0 AS depth,
    cc_comments.sharing_id,
    cc_comments.user_id,
    cc_comments.created_at,
    cc_comments.content,
    LPAD(cc_comments.id::text, 10, '0') AS sort_path
  FROM cc_comments
  WHERE cc_comments.parent_id IS NULL

  UNION ALL

  -- Recursive case: child comments
  SELECT
    cc_comments.id,
    cc_comments.parent_id,
    comment_tree.root_id,
    comment_tree.depth + 1,
    cc_comments.sharing_id,
    cc_comments.user_id,
    cc_comments.created_at,
    cc_comments.content,
    comment_tree.sort_path || '.' || LPAD(cc_comments.id::text, 10, '0')
  FROM cc_comments
  JOIN comment_tree ON cc_comments.parent_id = comment_tree.id
)
SELECT
  comment_tree.id,
  comment_tree.parent_id,
  comment_tree.root_id,
  comment_tree.depth,
  comment_tree.sharing_id,
  comment_tree.user_id,
  comment_tree.created_at,
  comment_tree.content,
  comment_tree.sort_path,

  -- display_name: Uses saved display_name, with fallback
  COALESCE(
    NULLIF(TRIM(cc_members.display_name), ''),
    NULLIF(TRIM(cc_members.first_name), ''),
    'User'
  ) AS display_name,

  cc_members.photo_url

FROM comment_tree
LEFT JOIN cc_members ON comment_tree.user_id = cc_members.auth_user_id;
