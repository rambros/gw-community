-- Cria tabela para rastrear notificações de grupo lidas por usuário
-- Permite marcar quais notificações (sharings do tipo 'notification') foram lidas por cada usuário

CREATE TABLE IF NOT EXISTS cc_sharing_reads (
    id BIGSERIAL PRIMARY KEY,
    sharing_id BIGINT NOT NULL REFERENCES cc_sharings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Garantir que um usuário só tenha um registro de leitura por notificação
    UNIQUE(sharing_id, user_id)
);

-- Índice para melhorar performance de consultas por usuário
CREATE INDEX IF NOT EXISTS idx_sharing_reads_user_id ON cc_sharing_reads(user_id);

-- Índice para melhorar performance de consultas por sharing
CREATE INDEX IF NOT EXISTS idx_sharing_reads_sharing_id ON cc_sharing_reads(sharing_id);

-- Índice composto para consultas que filtram por ambos
CREATE INDEX IF NOT EXISTS idx_sharing_reads_user_sharing ON cc_sharing_reads(user_id, sharing_id);

-- Habilitar RLS (Row Level Security)
ALTER TABLE cc_sharing_reads ENABLE ROW LEVEL SECURITY;

-- Policy: Usuários podem ver suas próprias leituras
CREATE POLICY "Users can view their own reads"
  ON cc_sharing_reads
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Usuários podem inserir suas próprias leituras
CREATE POLICY "Users can insert their own reads"
  ON cc_sharing_reads
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Usuários podem deletar suas próprias leituras (caso precise "desmarcar")
CREATE POLICY "Users can delete their own reads"
  ON cc_sharing_reads
  FOR DELETE
  USING (auth.uid() = user_id);

-- Comentário na tabela
COMMENT ON TABLE cc_sharing_reads IS 'Rastreia quais notificações do grupo foram lidas por cada usuário';
COMMENT ON COLUMN cc_sharing_reads.sharing_id IS 'ID da notificação (sharing com type=notification)';
COMMENT ON COLUMN cc_sharing_reads.user_id IS 'ID do usuário que leu a notificação';
COMMENT ON COLUMN cc_sharing_reads.read_at IS 'Timestamp de quando foi marcada como lida';
