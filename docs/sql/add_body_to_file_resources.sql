-- Markdown body for group resources of type 'text'.
-- Applied on the Portal project as migration add_body_to_file_resources.

ALTER TABLE public.cc_file_resources
  ADD COLUMN IF NOT EXISTS body TEXT;

COMMENT ON COLUMN public.cc_file_resources.body IS
  'Markdown body for resources of type text.';
