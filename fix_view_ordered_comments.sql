-- Fix cc_view_ordered_comments to use cc_members instead of cc_users
-- This fixes user names in comments

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
