-- Cria a view para favoritos de activities
-- Esta view junta cc_user_favorites com cc_step_activities

-- Remove a view se existir
DROP VIEW IF EXISTS cc_view_user_favorite_activities;

-- Cria a view
CREATE OR REPLACE VIEW cc_view_user_favorite_activities AS
SELECT
  -- Campos do favorito
  uf.id as favorite_id,
  uf.member_id,
  uf.created_at as favorited_at,

  -- Campos da activity (cc_step_activities)
  sa.id,
  sa.step_id,
  sa.order_in_step,
  sa.activity_prompt,
  sa.activity_type,
  sa.activity_label,
  sa.text,
  sa.audio_url,
  sa.audio_filename,
  sa.audio_duration,
  sa.video_url,
  sa.journal
FROM cc_user_favorites uf
INNER JOIN cc_step_activities sa ON sa.id = uf.content_id
WHERE uf.content_type = 'activity';

-- Habilita RLS na view
ALTER VIEW cc_view_user_favorite_activities SET (security_invoker = true);

-- Concede permissões de SELECT para usuários autenticados
GRANT SELECT ON cc_view_user_favorite_activities TO authenticated;
