-- Debug: Verificar se há favoritos de activities na tabela

-- 1. Ver todos os favoritos de activities
SELECT
  uf.id,
  uf.member_id,
  uf.content_type,
  uf.content_id,
  uf.created_at
FROM cc_user_favorites uf
WHERE uf.content_type = 'activity'
LIMIT 10;

-- 2. Ver se as activities existem na tabela cc_step_activities
SELECT
  sa.id,
  sa.activity_type,
  sa.activity_label,
  sa.activity_prompt
FROM cc_step_activities sa
WHERE sa.id IN (
  SELECT uf.content_id
  FROM cc_user_favorites uf
  WHERE uf.content_type = 'activity'
)
LIMIT 10;

-- 3. Testar a view diretamente
SELECT *
FROM cc_view_user_favorite_activities
LIMIT 10;

-- 4. Verificar se o member_id está correto
-- (substitua 'SEU_AUTH_USER_ID' pelo auth.uid() real)
SELECT
  cm.id as member_id,
  cm.auth_user_id
FROM cc_members cm
LIMIT 5;
