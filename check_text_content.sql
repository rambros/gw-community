-- Check the actual content of the text column in cc_sharings
SELECT
  id,
  title,
  LENGTH(text) as text_length,
  text,
  -- Remove HTML tags to see plain text
  REGEXP_REPLACE(text, '<[^>]*>', '', 'g') as plain_text,
  LENGTH(REGEXP_REPLACE(text, '<[^>]*>', '', 'g')) as plain_text_length
FROM cc_sharings
WHERE type = 'sharing'
ORDER BY id DESC
LIMIT 5;
