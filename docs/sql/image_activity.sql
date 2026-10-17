-- Image activities show a picture and a reflection written by the facilitator.
-- The participant does not upload anything.

alter table public.cc_step_activities
  add column if not exists image_url text;

comment on column public.cc_step_activities.image_url is
  'Image shown with an image activity. The participant only reads it.';

create or replace view public.cc_view_user_activities as
 select ua.id,
    ua.user_step_id,
    ua.user_id,
    sa.id as step_activity_id,
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
    sa.is_required,
    sa.image_url
   from cc_user_activities ua
     join cc_step_activities sa on sa.id = ua.step_activity_id;

alter table public.cc_user_activities
  drop column if exists image_url;
