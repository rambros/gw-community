-- One cc_events row can repeat. The app shows only the next occurrence.
-- Also repairs get_user_events, which still omitted end_date and event_type.

alter table public.cc_events
  add column if not exists recurrence text,
  add column if not exists recurrence_until date;

alter table public.cc_events
  drop constraint if exists cc_events_recurrence_check;

alter table public.cc_events
  add constraint cc_events_recurrence_check
  check (recurrence is null or recurrence in ('weekly', 'biweekly', 'monthly'));

comment on column public.cc_events.recurrence is
  'weekly, biweekly, or monthly. Null is a one-off event. event_date stays the first occurrence.';

comment on column public.cc_events.recurrence_until is
  'Last date an occurrence may start. Null repeats without an end.';

create or replace function public.get_user_events(user_id_input uuid)
returns setof public.cc_events
language sql
stable
as $$
  select
    e.id,
    e.title,
    e.description,
    e.facilitator_id,
    e.group_id,
    e.event_date,
    e.duration,
    e.event_image_url,
    e.event_audio_url,
    e.event_video_url,
    e.event_page_url,
    e.event_status,
    e.date_created,
    e.facilitator_name,
    (er.user_id is not null) as user_registered,
    e.event_time,
    e.visibility,
    e.end_date,
    e.event_type,
    e.recurrence,
    e.recurrence_until
  from public.cc_events e
  left join public.cc_event_registrations er
    on e.id = er.event_id and er.user_id = user_id_input
  order by e.event_date asc;
$$;
