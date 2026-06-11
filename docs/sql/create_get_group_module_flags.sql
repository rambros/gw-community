-- Returns the enable_library_module and enable_journey_module flags for all
-- groups the given user belongs to.
-- Uses SECURITY DEFINER so it bypasses RLS (same pattern as get_my_groups).
-- Called from HomeRepository.getGroupModuleFlags to decide which nav tabs to show.

CREATE OR REPLACE FUNCTION get_group_module_flags(user_input uuid)
RETURNS TABLE (
  enable_library_module boolean,
  enable_journey_module boolean
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT
    g.enable_library_module,
    g.enable_journey_module
  FROM cc_group_members gm
  JOIN cc_groups g ON g.id = gm.group_id
  WHERE gm.user_id = user_input;
$$;
