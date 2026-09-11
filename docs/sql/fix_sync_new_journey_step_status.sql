-- New journey steps added after users started were inserted as `closed`,
-- but the mobile app only unlocked `locked` steps — causing skips (e.g. 1 → 6).
-- Use `locked` so progression stays consistent with startJourney().

CREATE OR REPLACE FUNCTION public.sync_new_journey_step()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO cc_user_steps (user_journey_id, user_id, journey_step_id, date_started, step_status)
  SELECT
    uj.id,
    uj.user_id,
    NEW.id,
    NOW(),
    'locked'
  FROM cc_user_journeys uj
  WHERE uj.journey_id = NEW.journey_id;

  RETURN NEW;
END;
$function$;
