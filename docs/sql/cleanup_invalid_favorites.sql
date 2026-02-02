-- Remove favoritos de activities com IDs inválidos
-- (IDs que não existem em cc_step_activities)

DELETE FROM cc_user_favorites
WHERE content_type = 'activity'
  AND content_id NOT IN (
    SELECT id FROM cc_step_activities
  );

-- Verificar quantos favoritos válidos restaram
SELECT COUNT(*) as valid_favorites
FROM cc_user_favorites uf
WHERE uf.content_type = 'activity'
  AND EXISTS (
    SELECT 1 FROM cc_step_activities sa WHERE sa.id = uf.content_id
  );
