-- Add portal_item_id to cc_file_resources to distinguish portal-linked resources
-- from resources uploaded directly from a mobile device.
-- When a portal item is linked to a group via the admin portal or mobile library,
-- portal_item_id is set. Uploaded resources leave this column NULL.
ALTER TABLE cc_file_resources
ADD COLUMN IF NOT EXISTS portal_item_id INT REFERENCES portal_item(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_file_resources_portal_item_id
  ON cc_file_resources(portal_item_id);
