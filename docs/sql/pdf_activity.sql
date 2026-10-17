-- PDF activities show a document chosen by the facilitator.
-- The participant only reads it. activity_prompt is the same prompt as the other activities.

alter table public.cc_step_activities
  add column if not exists pdf_url text;

comment on column public.cc_step_activities.pdf_url is
  'PDF shown with a pdf activity. The participant only reads it.';

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
    sa.image_url,
    sa.pdf_url
   from cc_user_activities ua
     join cc_step_activities sa on sa.id = ua.step_activity_id;
