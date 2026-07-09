-- Migration: add transcript column to cc_step_activities
-- Also updates cc_view_user_activities and cc_view_user_favorite_activities

-- 1. Add transcript column
ALTER TABLE cc_step_activities
  ADD COLUMN IF NOT EXISTS transcript TEXT;

-- 2. Update cc_view_user_activities to include transcript
-- DROP + CREATE is required because PostgreSQL does not allow inserting a column
-- in the middle of an existing view with CREATE OR REPLACE.
DROP VIEW IF EXISTS cc_view_user_activities;

CREATE VIEW cc_view_user_activities AS
SELECT
  ua.id,
  ua.user_step_id,
  ua.user_id,
  sa.id AS step_activity_id,
  sa.activity_label,
  sa.activity_prompt,
  sa.activity_type,
  sa.audio_url,
  sa.journal,
  sa.text,
  sa.order_in_step,
  ua.date_started,
  ua.date_completed,
  ua.activity_status,
  ua.journal_saved,
  sa.transcript,
  sa.video_url
FROM cc_user_activities ua
JOIN cc_step_activities sa ON sa.id = ua.step_activity_id;

ALTER VIEW cc_view_user_activities SET (security_invoker = true);
GRANT SELECT ON cc_view_user_activities TO authenticated;

-- 3. Update cc_view_user_favorite_activities to include transcript
DROP VIEW IF EXISTS cc_view_user_favorite_activities;

CREATE VIEW cc_view_user_favorite_activities AS
SELECT
  uf.id AS favorite_id,
  uf.member_id,
  uf.created_at AS favorited_at,
  sa.id,
  sa.step_id,
  sa.order_in_step,
  sa.activity_prompt,
  sa.activity_type,
  sa.activity_label,
  sa.text,
  sa.audio_url,
  sa.audio_filename,
  sa.audio_duration,
  sa.video_url,
  sa.journal,
  j.title AS journey_title,
  s.step_number,
  s.title AS step_title,
  sa.transcript
FROM cc_user_favorites uf
INNER JOIN cc_step_activities sa ON sa.id = uf.content_id
LEFT JOIN cc_journey_steps s ON s.id = sa.step_id
LEFT JOIN cc_journeys j ON j.id = s.journey_id
WHERE uf.content_type = 'activity';

ALTER VIEW cc_view_user_favorite_activities SET (security_invoker = true);
GRANT SELECT ON cc_view_user_favorite_activities TO authenticated;
