-- Starts a journey in one database call: user journey, steps, and activities.
-- Returns true when this call created the journey, false when it already existed.

CREATE OR REPLACE FUNCTION public.start_user_journey(p_journey_id bigint)
RETURNS boolean
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_user_journey_id bigint;
  v_now timestamptz := now();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not authenticated';
  END IF;

  SELECT id
    INTO v_user_journey_id
  FROM cc_user_journeys
  WHERE user_id = v_user_id
    AND journey_id = p_journey_id
  LIMIT 1;

  IF v_user_journey_id IS NOT NULL THEN
    RETURN false;
  END IF;

  INSERT INTO cc_user_journeys (
    user_id,
    journey_id,
    date_started,
    last_access_date,
    journey_status
  ) VALUES (
    v_user_id,
    p_journey_id,
    v_now,
    v_now,
    'started'
  )
  RETURNING id INTO v_user_journey_id;

  INSERT INTO cc_user_steps (
    user_journey_id,
    user_id,
    journey_step_id,
    date_started,
    step_status
  )
  SELECT
    v_user_journey_id,
    v_user_id,
    s.id,
    v_now,
    CASE
      WHEN row_number() OVER (ORDER BY s.step_number, s.id) = 1 THEN 'open'
      ELSE 'locked'
    END
  FROM cc_journey_steps s
  WHERE s.journey_id = p_journey_id;

  INSERT INTO cc_user_activities (
    step_activity_id,
    user_step_id,
    user_id,
    date_started,
    activity_status
  )
  SELECT
    sa.id,
    us.id,
    v_user_id,
    v_now,
    'open'
  FROM cc_step_activities sa
  JOIN cc_user_steps us
    ON us.journey_step_id = sa.step_id
   AND us.user_journey_id = v_user_journey_id
   AND us.user_id = v_user_id;

  RETURN true;
END;
$$;

REVOKE ALL ON FUNCTION public.start_user_journey(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.start_user_journey(bigint) TO authenticated, service_role;

NOTIFY pgrst, 'reload schema';
