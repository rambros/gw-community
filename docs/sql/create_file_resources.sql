-- ============================================================
-- File Resources Feature
-- Tabela de recursos de arquivo (PDF, áudio, vídeo) por grupo
-- ============================================================

-- 1. Tabela principal de recursos
CREATE TABLE cc_file_resources (
  id          BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title       TEXT NOT NULL,
  description TEXT,
  url         TEXT NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('pdf', 'audio', 'video')),
  status      TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  published_at TIMESTAMPTZ,
  created_by  UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Junction table: recurso ↔ grupo (many-to-many)
CREATE TABLE cc_file_resource_groups (
  id          BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  resource_id BIGINT NOT NULL REFERENCES cc_file_resources(id) ON DELETE CASCADE,
  group_id    BIGINT NOT NULL REFERENCES cc_groups(id) ON DELETE CASCADE,
  added_by    UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(resource_id, group_id)
);

CREATE INDEX idx_frgp_group    ON cc_file_resource_groups(group_id);
CREATE INDEX idx_frgp_resource ON cc_file_resource_groups(resource_id);

-- 3. Row Level Security
ALTER TABLE cc_file_resources       ENABLE ROW LEVEL SECURITY;
ALTER TABLE cc_file_resource_groups ENABLE ROW LEVEL SECURITY;

-- Admins: acesso total a cc_file_resources
CREATE POLICY "admins_all_cc_file_resources" ON cc_file_resources
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM cc_members
      WHERE auth_user_id = auth.uid()
        AND 'admin' = ANY(user_role)
    )
  );

-- Group managers: CRUD para recursos dos seus grupos
CREATE POLICY "managers_all_cc_file_resources" ON cc_file_resources
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM cc_file_resource_groups frg
      JOIN cc_group_members gm ON gm.group_id = frg.group_id
      WHERE frg.resource_id = cc_file_resources.id
        AND gm.user_id = auth.uid()
        AND gm.user_role = 'manager'
    )
  );

-- Membros: leitura de recursos publicados nos seus grupos
CREATE POLICY "members_read_published_cc_file_resources" ON cc_file_resources
  FOR SELECT
  USING (
    status = 'published' AND
    EXISTS (
      SELECT 1 FROM cc_file_resource_groups frg
      JOIN cc_group_members gm ON gm.group_id = frg.group_id
      WHERE frg.resource_id = cc_file_resources.id
        AND gm.user_id = auth.uid()
    )
  );

-- Policies para junction table
CREATE POLICY "admins_all_cc_file_resource_groups" ON cc_file_resource_groups
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM cc_members
      WHERE auth_user_id = auth.uid()
        AND 'admin' = ANY(user_role)
    )
  );

CREATE POLICY "managers_all_cc_file_resource_groups" ON cc_file_resource_groups
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM cc_group_members gm
      WHERE gm.group_id = cc_file_resource_groups.group_id
        AND gm.user_id = auth.uid()
        AND gm.user_role = 'manager'
    )
  );

CREATE POLICY "members_read_cc_file_resource_groups" ON cc_file_resource_groups
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM cc_group_members gm
      WHERE gm.group_id = cc_file_resource_groups.group_id
        AND gm.user_id = auth.uid()
    )
  );
