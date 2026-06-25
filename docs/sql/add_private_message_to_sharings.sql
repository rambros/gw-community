-- Adiciona suporte a mensagens privadas (de facilitador/admin para um membro específico)

-- Passo 1: adicionar coluna na tabela
ALTER TABLE cc_sharings
  ADD COLUMN IF NOT EXISTS recipient_user_id UUID REFERENCES auth.users(id);

-- Passo 2: recriar a view com recipient_user_id NO FINAL (obrigatório no CREATE OR REPLACE)
CREATE OR REPLACE VIEW cc_view_notifications_users AS
SELECT
  s.id,
  s.created_at,
  s.updated_at,
  s.title,
  s.text,
  s.privacy,
  s.user_id,
  s.group_id,
  s.visibility,
  s.type,
  s.locked,
  TRIM(COALESCE(m.first_name, '') || ' ' || COALESCE(m.last_name, '')) AS full_name,
  m.display_name,
  m.photo_url,
  g.name AS group_name,
  s.recipient_user_id
FROM cc_sharings s
LEFT JOIN cc_members m ON m.auth_user_id = s.user_id
LEFT JOIN cc_groups g ON g.id = s.group_id
WHERE s.type = 'notification';
