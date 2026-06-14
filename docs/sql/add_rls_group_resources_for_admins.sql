-- Allow admin portal users (cc_users) to manage cc_group_resources
-- Admin portal users are authenticated via auth.users but exist in cc_users, not cc_members.
-- Without this policy they are blocked by existing RLS that only covers cc_members.

CREATE POLICY "cc_users_all_group_resources"
  ON cc_group_resources
  FOR ALL
  USING (
    EXISTS (SELECT 1 FROM cc_users WHERE id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM cc_users WHERE id = auth.uid())
  );
