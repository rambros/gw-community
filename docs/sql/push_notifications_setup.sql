-- ============================================================
-- Push Notifications Setup
-- Run this in the Supabase SQL Editor
-- ============================================================

-- 1. Device tokens table
CREATE TABLE IF NOT EXISTS cc_device_tokens (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token   text NOT NULL,
  platform    text NOT NULL CHECK (platform IN ('ios', 'android')),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, fcm_token)
);

-- Index for fast lookup by user
CREATE INDEX IF NOT EXISTS idx_cc_device_tokens_user_id ON cc_device_tokens (user_id);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_cc_device_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cc_device_tokens_updated_at ON cc_device_tokens;
CREATE TRIGGER trg_cc_device_tokens_updated_at
  BEFORE UPDATE ON cc_device_tokens
  FOR EACH ROW EXECUTE FUNCTION update_cc_device_tokens_updated_at();

-- RLS
ALTER TABLE cc_device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own tokens"
  ON cc_device_tokens
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Service role bypasses RLS (used by edge function)
CREATE POLICY "Service role full access"
  ON cc_device_tokens
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- 2. cc_notification_preferences
--    Stores per-user notification toggles.
--    Includes push_global and in_app_global master switches.
-- ============================================================

CREATE TABLE IF NOT EXISTS cc_notification_preferences (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_type text        NOT NULL,
  enabled           boolean     NOT NULL DEFAULT true,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, notification_type)
);

CREATE INDEX IF NOT EXISTS idx_cc_notification_prefs_user_id
  ON cc_notification_preferences (user_id);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_cc_notification_preferences_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cc_notification_prefs_updated_at ON cc_notification_preferences;
CREATE TRIGGER trg_cc_notification_prefs_updated_at
  BEFORE UPDATE ON cc_notification_preferences
  FOR EACH ROW EXECUTE FUNCTION update_cc_notification_preferences_updated_at();

-- RLS
ALTER TABLE cc_notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own preferences"
  ON cc_notification_preferences
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role full access to preferences"
  ON cc_notification_preferences
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================
-- Verification
-- ============================================================
SELECT 'cc_device_tokens created' AS status;
SELECT 'cc_notification_preferences created' AS status;
