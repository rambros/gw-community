-- My Journeys reads cc_view_user_journeys. Without is_public the app showed
-- every started journey as public. Available journeys must stay limited to
-- journeys marked public.

CREATE OR REPLACE VIEW public.cc_view_user_journeys
WITH (security_invoker = true) AS
SELECT
  cc_user_journeys.id,
  cc_user_journeys.journey_id,
  cc_user_journeys.user_id,
  cc_journeys.title,
  cc_journeys.description,
  cc_journeys.image_url,
  cc_journeys.steps_total,
  cc_journeys.enable_date_control,
  cc_journeys.days_to_wait_between_steps,
  cc_journeys.is_featured,
  cc_user_journeys.steps_completed,
  cc_user_journeys.last_access_date,
  cc_user_journeys.journey_status,
  cc_journeys.is_public
FROM cc_user_journeys
JOIN cc_journeys ON cc_user_journeys.journey_id = cc_journeys.id;

CREATE OR REPLACE VIEW public.cc_view_avail_journeys
WITH (security_invoker = true) AS
SELECT
  j.id,
  j.title,
  j.description,
  j.image_url,
  j.steps_total,
  j.is_featured,
  m.auth_user_id AS user_id
FROM cc_journeys j
CROSS JOIN cc_members m
WHERE j.is_public IS TRUE
  AND NOT EXISTS (
    SELECT 1
    FROM cc_user_journeys uj
    WHERE uj.journey_id = j.id
      AND uj.user_id = m.auth_user_id
      AND uj.journey_status <> 'non_started'::text
  );
