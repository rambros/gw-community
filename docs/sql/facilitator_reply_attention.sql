-- Facilitator reply attention.
-- 1. Reopening a group message updates read_at (needs an UPDATE policy).
-- 2. Push grouping remembers the last ping per facilitator and message.

DROP POLICY IF EXISTS "Users can update their own reads" ON public.cc_sharing_reads;
CREATE POLICY "Users can update their own reads"
  ON public.cc_sharing_reads
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.cc_comment_reply_alerts (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sharing_id bigint NOT NULL REFERENCES public.cc_sharings(id) ON DELETE CASCADE,
  last_pushed_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, sharing_id)
);

ALTER TABLE public.cc_comment_reply_alerts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.cc_comment_reply_alerts FROM anon, authenticated;

COMMENT ON TABLE public.cc_comment_reply_alerts IS
  'Last push sent to a facilitator about new replies on a group message. Service role only.';

CREATE INDEX IF NOT EXISTS idx_cc_comments_sharing_created
  ON public.cc_comments (sharing_id, created_at);

-- Comment and read times follow the database clock. A device clock that is
-- behind would otherwise store a reply as happening before the facilitator opened it.

CREATE OR REPLACE FUNCTION public.stamp_comment_created_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.created_at := now();
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.stamp_comment_created_at() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.stamp_comment_created_at() TO authenticated, service_role;

DROP TRIGGER IF EXISTS cc_comments_stamp_created_at ON public.cc_comments;
CREATE TRIGGER cc_comments_stamp_created_at
  BEFORE INSERT ON public.cc_comments
  FOR EACH ROW
  EXECUTE FUNCTION public.stamp_comment_created_at();

CREATE OR REPLACE FUNCTION public.stamp_sharing_read_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.read_at := now();
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.stamp_sharing_read_at() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.stamp_sharing_read_at() TO authenticated, service_role;

DROP TRIGGER IF EXISTS cc_sharing_reads_stamp_read_at ON public.cc_sharing_reads;
CREATE TRIGGER cc_sharing_reads_stamp_read_at
  BEFORE INSERT OR UPDATE ON public.cc_sharing_reads
  FOR EACH ROW
  EXECUTE FUNCTION public.stamp_sharing_read_at();
