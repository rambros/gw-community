-- Activity required/optional flag.
-- Required (default) counts toward opening the next journey step.
-- Optional activities stay on the step and do not block that calculation.

ALTER TABLE public.cc_step_activities
  ADD COLUMN IF NOT EXISTS is_required boolean NOT NULL DEFAULT true;

COMMENT ON COLUMN public.cc_step_activities.is_required IS
  'When false, the activity stays available but does not block opening the next journey step.';

CREATE OR REPLACE VIEW public.cc_view_user_activities AS
 SELECT ua.id,
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
    sa.video_url,
    sa.animation_url,
    sa.animation_media_type,
    sa.is_required
   FROM cc_user_activities ua
     JOIN cc_step_activities sa ON sa.id = ua.step_activity_id;

NOTIFY pgrst, 'reload schema';
