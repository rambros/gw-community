-- Facilitator pin for group messages.
-- New view columns stay at the end so CREATE OR REPLACE remains valid.

ALTER TABLE public.cc_sharings
  ADD COLUMN IF NOT EXISTS is_pinned boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS pinned_at timestamptz;

COMMENT ON COLUMN public.cc_sharings.is_pinned IS
  'Facilitator pin. Pinned group messages stay at the top of the messages list.';
COMMENT ON COLUMN public.cc_sharings.pinned_at IS
  'When the facilitator last pinned this message.';

CREATE OR REPLACE VIEW public.cc_view_notifications_users
WITH (security_invoker = true) AS
SELECT
  s.id,
  s.created_at,
  s.updated_at,
  s.title,
  s.text,
  s.privacy,
  s.user_id,
  s.group_id,
  s.visibility,
  s.type,
  s.locked,
  TRIM(BOTH FROM (COALESCE(m.first_name, ''::text) || ' '::text) || COALESCE(m.last_name, ''::text)) AS full_name,
  m.display_name,
  m.photo_url,
  g.name AS group_name,
  s.recipient_user_id,
  s.is_pinned,
  s.pinned_at
FROM public.cc_sharings s
  LEFT JOIN public.cc_members m ON m.auth_user_id = s.user_id
  LEFT JOIN public.cc_groups g ON g.id = s.group_id
WHERE s.type = 'notification'::text;
