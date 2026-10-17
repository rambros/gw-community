-- Creates one step activity from a portal item (library or recording).
-- Admin can target any step. Admin here is is_portal_admin() or a cc_members
-- role of admin, which is the list the mobile app uses. A group manager or
-- group admin can target a step only when that journey is linked to a group
-- they manage. The function copies the media the
-- caller sends; it does not keep a foreign key to portal_item.
--
-- Participants who already started the journey pick the new activity up when
-- the app syncs missing activities on the step.
--
-- Apply this before using Link to Journeys. PDF activities also need
-- docs/sql/pdf_activity.sql so cc_step_activities.pdf_url exists.

CREATE OR REPLACE FUNCTION public.can_create_step_activity(p_step_id bigint)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1
      FROM public.cc_journey_steps
      WHERE id = p_step_id
    )
    AND (
      public.is_portal_admin()
      OR EXISTS (
        SELECT 1
        FROM public.cc_members AS portal_member
        WHERE portal_member.auth_user_id = auth.uid()
          AND EXISTS (
            SELECT 1
            FROM unnest(coalesce(portal_member.user_role, ARRAY[]::text[])) AS role(value)
            WHERE upper(replace(btrim(value), ' ', '_')) = 'ADMIN'
          )
      )
      OR EXISTS (
        SELECT 1
        FROM public.cc_journey_steps AS steps
        JOIN public.cc_group_journeys AS links
          ON links.journey_id = steps.journey_id
         AND links.deleted_at IS NULL
        JOIN public.cc_group_members AS members
          ON members.group_id = links.group_id
        WHERE steps.id = p_step_id
          AND members.user_id::text = auth.uid()::text
          AND upper(replace(btrim(coalesce(members.user_role, '')), ' ', '_'))
              IN ('GROUP_MANAGER', 'GROUPMANAGER', 'MANAGER', 'ADMIN')
      )
    );
$$;

REVOKE ALL ON FUNCTION public.can_create_step_activity(bigint) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.can_create_step_activity(bigint) FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.next_step_activity_order(p_step_id bigint)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_next integer;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.cc_journey_steps WHERE id = p_step_id
  ) THEN
    RAISE EXCEPTION 'step not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT public.can_create_step_activity(p_step_id) THEN
    RAISE EXCEPTION 'not allowed' USING ERRCODE = '42501';
  END IF;

  SELECT coalesce(max(order_in_step), 0) + 1
    INTO v_next
  FROM public.cc_step_activities
  WHERE step_id = p_step_id;

  RETURN v_next;
END;
$$;

CREATE OR REPLACE FUNCTION public.create_step_activity_from_content(
  p_step_id bigint,
  p_activity_label text,
  p_activity_prompt text,
  p_activity_type text,
  p_order_in_step integer DEFAULT NULL,
  p_is_required boolean DEFAULT true,
  p_audio_url text DEFAULT NULL,
  p_audio_filename text DEFAULT NULL,
  p_audio_duration text DEFAULT NULL,
  p_transcript text DEFAULT NULL,
  p_video_url text DEFAULT NULL,
  p_pdf_url text DEFAULT NULL,
  p_text text DEFAULT NULL
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_label text := nullif(btrim(p_activity_label), '');
  v_prompt text := nullif(btrim(p_activity_prompt), '');
  v_type text := lower(nullif(btrim(p_activity_type), ''));
  v_audio_url text := nullif(btrim(p_audio_url), '');
  v_video_url text := nullif(btrim(p_video_url), '');
  v_pdf_url text := nullif(btrim(p_pdf_url), '');
  v_text text := nullif(btrim(p_text), '');
  v_order integer;
  v_row record;
  v_id bigint;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not authenticated' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.cc_journey_steps WHERE id = p_step_id
  ) THEN
    RAISE EXCEPTION 'step not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT public.can_create_step_activity(p_step_id) THEN
    RAISE EXCEPTION 'not allowed' USING ERRCODE = '42501';
  END IF;

  IF v_label IS NULL THEN
    RAISE EXCEPTION 'activity label is required' USING ERRCODE = '22023';
  END IF;
  IF char_length(v_label) > 40 THEN
    RAISE EXCEPTION 'activity label is too long' USING ERRCODE = '22023';
  END IF;
  IF v_prompt IS NULL THEN
    RAISE EXCEPTION 'activity prompt is required' USING ERRCODE = '22023';
  END IF;
  IF char_length(v_prompt) > 130 THEN
    RAISE EXCEPTION 'activity prompt is too long' USING ERRCODE = '22023';
  END IF;
  IF v_type IS NULL OR v_type NOT IN ('audio', 'video', 'pdf', 'text') THEN
    RAISE EXCEPTION 'unsupported activity type' USING ERRCODE = '22023';
  END IF;

  IF v_type = 'audio' AND v_audio_url IS NULL THEN
    RAISE EXCEPTION 'media is required' USING ERRCODE = '22023';
  ELSIF v_type = 'video' AND v_video_url IS NULL THEN
    RAISE EXCEPTION 'media is required' USING ERRCODE = '22023';
  ELSIF v_type = 'pdf' AND v_pdf_url IS NULL THEN
    RAISE EXCEPTION 'media is required' USING ERRCODE = '22023';
  ELSIF v_type = 'text' AND v_text IS NULL THEN
    RAISE EXCEPTION 'media is required' USING ERRCODE = '22023';
  END IF;

  PERFORM 1
  FROM public.cc_journey_steps
  WHERE id = p_step_id
  FOR UPDATE;

  IF p_order_in_step IS NULL THEN
    SELECT coalesce(max(order_in_step), 0) + 1
      INTO v_order
    FROM public.cc_step_activities
    WHERE step_id = p_step_id;
  ELSIF p_order_in_step < 1 THEN
    RAISE EXCEPTION 'order must be 1 or more' USING ERRCODE = '22023';
  ELSE
    v_order := p_order_in_step;
  END IF;

  FOR v_row IN
    SELECT id, order_in_step
    FROM public.cc_step_activities
    WHERE step_id = p_step_id
      AND order_in_step >= v_order
    ORDER BY order_in_step DESC
  LOOP
    UPDATE public.cc_step_activities
    SET order_in_step = v_row.order_in_step + 1
    WHERE id = v_row.id;
  END LOOP;

  INSERT INTO public.cc_step_activities (
    step_id,
    order_in_step,
    is_required,
    activity_prompt,
    activity_type,
    activity_label,
    text,
    audio_url,
    audio_filename,
    audio_duration,
    video_url,
    pdf_url,
    transcript
  ) VALUES (
    p_step_id,
    v_order,
    coalesce(p_is_required, true),
    v_prompt,
    v_type,
    v_label,
    CASE WHEN v_type = 'text' THEN v_text ELSE NULL END,
    CASE WHEN v_type = 'audio' THEN v_audio_url ELSE NULL END,
    CASE
      WHEN v_type = 'audio' THEN nullif(btrim(p_audio_filename), '')
      ELSE NULL
    END,
    CASE
      WHEN v_type = 'audio' THEN nullif(btrim(p_audio_duration), '')
      ELSE NULL
    END,
    CASE WHEN v_type = 'video' THEN v_video_url ELSE NULL END,
    CASE WHEN v_type = 'pdf' THEN v_pdf_url ELSE NULL END,
    CASE
      WHEN v_type = 'audio' THEN nullif(btrim(p_transcript), '')
      ELSE NULL
    END
  )
  RETURNING id INTO v_id;

  INSERT INTO public.cc_user_activities (
    step_activity_id,
    user_step_id,
    user_id,
    date_started,
    activity_status
  )
  SELECT
    v_id,
    user_steps.id,
    user_steps.user_id,
    now(),
    'open'
  FROM public.cc_user_steps AS user_steps
  WHERE user_steps.journey_step_id = p_step_id
    AND user_steps.user_id IS NOT NULL
    AND NOT EXISTS (
      SELECT 1
      FROM public.cc_user_activities AS existing
      WHERE existing.step_activity_id = v_id
        AND existing.user_step_id = user_steps.id
    );

  RETURN v_id;
END;
$$;

REVOKE ALL ON FUNCTION public.next_step_activity_order(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.next_step_activity_order(bigint) TO authenticated, service_role;

REVOKE ALL ON FUNCTION public.create_step_activity_from_content(
  bigint, text, text, text, integer, boolean, text, text, text, text, text, text, text
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_step_activity_from_content(
  bigint, text, text, text, integer, boolean, text, text, text, text, text, text, text
) TO authenticated, service_role;

NOTIFY pgrst, 'reload schema';
