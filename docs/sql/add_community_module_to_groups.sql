-- Add enable_community_module column to cc_groups.
-- Default TRUE so existing groups remain visible until explicitly disabled.
ALTER TABLE cc_groups
ADD COLUMN IF NOT EXISTS enable_community_module BOOLEAN DEFAULT TRUE;

-- Update get_group_module_flags to include enable_community_module.
-- DROP required because return type changes (adding a new OUT column).
DROP FUNCTION IF EXISTS get_group_module_flags(uuid);
CREATE OR REPLACE FUNCTION get_group_module_flags(user_input uuid)
RETURNS TABLE (
  enable_library_module  boolean,
  enable_journey_module  boolean,
  enable_community_module boolean
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT
    g.enable_library_module,
    g.enable_journey_module,
    g.enable_community_module
  FROM cc_group_members gm
  JOIN cc_groups g ON g.id = gm.group_id
  WHERE gm.user_id = user_input;
$$;
