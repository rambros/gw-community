-- Read-only "view as member" for app admins (cc_members.user_role contains ADMIN).
-- Does not switch the Supabase session. Callers keep auth.uid() as themselves.
-- Journeys and steps are blocked by RLS on cc_user_journeys for anyone who is
-- not the row owner or a portal admin (cc_users). These functions bypass that
-- only after confirming the caller is an app admin.

CREATE OR REPLACE FUNCTION public.app_caller_is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM cc_members
    WHERE auth_user_id = auth.uid()
      AND 'ADMIN' = ANY (user_role)
  );
$$;

REVOKE ALL ON FUNCTION public.app_caller_is_admin() FROM PUBLIC, anon, authenticated;

DROP FUNCTION IF EXISTS public.admin_view_user_journeys(uuid);

CREATE OR REPLACE FUNCTION public.admin_view_user_journeys(target_auth_user_id uuid)
RETURNS TABLE (
  id bigint,
  journey_id bigint,
  user_id uuid,
  title text,
  description text,
  image_url text,
  steps_total smallint,
  enable_date_control boolean,
  days_to_wait_between_steps integer,
  is_featured boolean,
  steps_completed smallint,
  last_access_date timestamptz,
  journey_status text,
  is_public boolean
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL OR NOT public.app_caller_is_admin() THEN
    RAISE EXCEPTION 'not authorized' USING ERRCODE = '42501';
  END IF;

  IF target_auth_user_id IS NULL THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    uj.id,
    uj.journey_id,
    uj.user_id,
    j.title,
    j.description,
    j.image_url,
    j.steps_total,
    j.enable_date_control,
    j.days_to_wait_between_steps,
    j.is_featured,
    uj.steps_completed,
    uj.last_access_date,
    uj.journey_status,
    j.is_public
  FROM cc_user_journeys uj
  JOIN cc_journeys j ON j.id = uj.journey_id
  WHERE uj.user_id = target_auth_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_view_user_steps(
  target_auth_user_id uuid,
  p_journey_id bigint DEFAULT NULL
)
RETURNS TABLE (
  id bigint,
  user_journey_id bigint,
  journey_id bigint,
  user_id uuid,
  journey_step_id bigint,
  title text,
  description text,
  step_number smallint,
  date_started timestamptz,
  date_completed timestamptz,
  step_status text,
  section_id bigint,
  section_title text,
  section_order smallint
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL OR NOT public.app_caller_is_admin() THEN
    RAISE EXCEPTION 'not authorized' USING ERRCODE = '42501';
  END IF;

  IF target_auth_user_id IS NULL THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    us.id,
    us.user_journey_id,
    uj.journey_id,
    us.user_id,
    us.journey_step_id,
    js.title,
    js.description,
    js.step_number,
    us.date_started,
    us.date_completed,
    us.step_status,
    js.section_id,
    sec.title AS section_title,
    sec.section_order
  FROM cc_user_steps us
  JOIN cc_user_journeys uj ON us.user_journey_id = uj.id
  JOIN cc_journey_steps js ON us.journey_step_id = js.id
  LEFT JOIN cc_journey_sections sec ON js.section_id = sec.id
  WHERE us.user_id = target_auth_user_id
    AND (p_journey_id IS NULL OR uj.journey_id = p_journey_id)
  ORDER BY js.step_number, us.id;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_view_user_journeys(uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.admin_view_user_journeys(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.admin_view_user_steps(uuid, bigint) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.admin_view_user_steps(uuid, bigint) TO authenticated;
