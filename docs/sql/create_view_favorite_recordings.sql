-- Cria a view para favoritos de recordings
-- Esta view junta cc_user_favorites com view_content

-- Remove a view se existir
DROP VIEW IF EXISTS cc_view_user_favorite_recordings;

-- Cria a view
CREATE OR REPLACE VIEW cc_view_user_favorite_recordings AS
SELECT
  -- Campos do favorito
  uf.id as favorite_id,
  uf.member_id,
  uf.created_at as favorited_at,

  -- Campos do content (view_content)
  vc.content_id,
  vc.title,
  vc.description,
  vc.authors_names,
  vc.midia_type,
  vc.audio_url,
  vc.midia_file_url,
  vc.cott_event_id,
  vc.event_name,
  vc.transcript
FROM cc_user_favorites uf
INNER JOIN view_content vc ON vc.content_id = uf.content_id
WHERE uf.content_type = 'recording';

-- Habilita RLS na view
ALTER VIEW cc_view_user_favorite_recordings SET (security_invoker = true);

-- Concede permissões de SELECT para usuários autenticados
GRANT SELECT ON cc_view_user_favorite_recordings TO authenticated;
