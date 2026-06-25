-- Add 'text' to the allowed types in cc_file_resources
-- Required to support linking portal text-type content items to groups.

ALTER TABLE cc_file_resources
  DROP CONSTRAINT IF EXISTS cc_file_resources_type_check;

ALTER TABLE cc_file_resources
  ADD CONSTRAINT cc_file_resources_type_check
  CHECK (type IN ('pdf', 'audio', 'video', 'text'));
