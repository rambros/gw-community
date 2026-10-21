-- Group-only community events are visible to members of that group.
-- Replaces the public "Full access" policy, which let every role read and
-- write every row in cc_events and cc_event_registrations.
-- Portal admins keep "Admins full access" (is_portal_admin()).

create index if not exists cc_events_group_id_idx
  on public.cc_events (group_id);

create or replace function public.user_can_read_community_event(
  event_visibility text,
  event_group_id bigint,
  event_facilitator_id uuid,
  reader_id uuid
)
returns boolean
language sql
stable
as $$
  select
    reader_id is not null
    and (
      nullif(btrim(event_visibility), '') = 'everyone'
      or event_facilitator_id = reader_id
      or (
        event_group_id is null
        and nullif(btrim(event_visibility), '') is null
      )
      or (
        coalesce(nullif(btrim(event_visibility), ''), 'group_only') = 'group_only'
        and event_group_id is not null
        and event_group_id in (
          select gm.group_id
          from public.cc_group_members gm
          where gm.user_id = reader_id
        )
      )
    );
$$;

revoke all on function public.user_can_read_community_event(text, bigint, uuid, uuid) from public;
grant execute on function public.user_can_read_community_event(text, bigint, uuid, uuid) to authenticated;

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
  where public.user_can_read_community_event(
    e.visibility,
    e.group_id,
    e.facilitator_id,
    user_id_input
  )
  order by e.event_date asc;
$$;

drop policy if exists "Full access" on public.cc_events;

create policy "Read visible community events"
on public.cc_events
for select
to authenticated
using (
  public.user_can_read_community_event(
    visibility,
    group_id,
    facilitator_id,
    (select auth.uid())
  )
);

create policy "Group managers manage group events"
on public.cc_events
for all
to authenticated
using (
  group_id in (
    select gm.group_id
    from public.cc_group_members gm
    where gm.user_id = (select auth.uid())
      and upper(gm.user_role) in ('GROUP_MANAGER', 'ADMIN')
  )
)
with check (
  group_id in (
    select gm.group_id
    from public.cc_group_members gm
    where gm.user_id = (select auth.uid())
      and upper(gm.user_role) in ('GROUP_MANAGER', 'ADMIN')
  )
);

create policy "Creators manage ungrouped events"
on public.cc_events
for all
to authenticated
using (
  group_id is null
  and facilitator_id = (select auth.uid())
)
with check (
  group_id is null
  and facilitator_id = (select auth.uid())
);

create policy "Facilitators update their events"
on public.cc_events
for update
to authenticated
using (facilitator_id = (select auth.uid()))
with check (facilitator_id = (select auth.uid()));

create policy "Facilitators delete their events"
on public.cc_events
for delete
to authenticated
using (facilitator_id = (select auth.uid()));

drop policy if exists "Full access" on public.cc_event_registrations;

create policy "Read registrations of visible events"
on public.cc_event_registrations
for select
to authenticated
using (
  user_id = (select auth.uid())
  or exists (
    select 1
    from public.cc_events e
    where e.id = cc_event_registrations.event_id
  )
);

create policy "Register yourself for a visible event"
on public.cc_event_registrations
for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.cc_events e
    where e.id = event_id
  )
);

create policy "Leave an event or manage your group"
on public.cc_event_registrations
for delete
to authenticated
using (
  user_id = (select auth.uid())
  or exists (
    select 1
    from public.cc_events e
    join public.cc_group_members gm on gm.group_id = e.group_id
    where e.id = cc_event_registrations.event_id
      and gm.user_id = (select auth.uid())
      and upper(gm.user_role) in ('GROUP_MANAGER', 'ADMIN')
  )
);
