-- Teste 1: Verificar se há favoritos de activities na tabela base
SELECT
  uf.id,
  uf.member_id,
  uf.content_type,
  uf.content_id,
  uf.created_at
FROM cc_user_favorites uf
WHERE uf.content_type = 'activity'
  AND uf.member_id = 'e9747f08-c768-4150-9846-41546b92b3e5'
ORDER BY uf.created_at DESC;

-- Teste 2: Verificar se a activity existe
SELECT
  sa.id,
  sa.activity_type,
  sa.activity_label,
  sa.activity_prompt
FROM cc_step_activities sa
WHERE sa.id = 486;

-- Teste 3: Testar o JOIN manualmente (igual à view)
SELECT
  uf.id as favorite_id,
  uf.member_id,
  uf.created_at as favorited_at,
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
WHERE uf.content_type = 'activity'
  AND uf.member_id = 'e9747f08-c768-4150-9846-41546b92b3e5';

-- Teste 4: Verificar se a view existe e está funcionando
SELECT *
FROM cc_view_user_favorite_activities
WHERE member_id = 'e9747f08-c768-4150-9846-41546b92b3e5';

-- Teste 5: Verificar se a view tem a política RLS correta
SELECT
  schemaname,
  viewname,
  viewowner,
  definition
FROM pg_views
WHERE viewname = 'cc_view_user_favorite_activities';
