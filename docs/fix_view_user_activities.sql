-- Primeiro, vamos ver a view atual para não perder a definição
-- Execute este SELECT primeiro e salve o resultado
SELECT definition
FROM pg_views
WHERE viewname = 'cc_view_user_activities';

-- Depois, vamos recriar a view adicionando o campo step_activity_id
-- IMPORTANTE: Substitua o CREATE OR REPLACE abaixo pela definição atual da view
-- mas adicione o campo step_activity_id (activity_id da tabela cc_step_activities)

-- EXEMPLO (ajuste conforme a view real):
-- DROP VIEW IF EXISTS cc_view_user_activities;
--
-- CREATE OR REPLACE VIEW cc_view_user_activities AS
-- SELECT
--   ua.id,
--   ua.user_step_id,
--   ua.user_id,
--   sa.id as step_activity_id,  -- <-- ADICIONAR ESTA LINHA
--   sa.activity_label,
--   sa.activity_prompt,
--   sa.activity_type,
--   sa.audio_url,
--   sa.journal,
--   sa.text,
--   sa.order_in_step,
--   ua.date_started,
--   ua.date_completed,
--   ua.activity_status,
--   ua.journal_saved
-- FROM cc_user_activities ua
-- JOIN cc_step_activities sa ON sa.id = ua.step_activity_id;
