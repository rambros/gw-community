-- Adds auto_moderation_enabled column to cc_groups.
-- When true, experiences published to this group are immediately set to
-- 'approved' without going through the manual moderation queue.
-- Default is false (manual moderation, existing behaviour).

ALTER TABLE cc_groups
  ADD COLUMN IF NOT EXISTS auto_moderation_enabled boolean NOT NULL DEFAULT false;
