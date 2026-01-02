-- Recriar a view cc_view_user_activities adicionando step_activity_id
-- Esta view junta cc_user_activities com cc_step_activities

DROP VIEW IF EXISTS cc_view_user_activities CASCADE;

CREATE OR REPLACE VIEW cc_view_user_activities AS
SELECT
  ua.id,
  ua.user_step_id,
  ua.user_id,
  ua.step_activity_id,  -- <-- ADICIONANDO ESTE CAMPO
  sa.activity_label,
  sa.activity_prompt,
  sa.activity_type,
  sa.audio_url,
  sa.journal,
  sa.text,
  sa.order_in_step,
  ua.date_started,
  ua.date_completed,
  ua.activity_status,
  ua.journal_saved
FROM cc_user_activities ua
LEFT JOIN cc_step_activities sa ON sa.id = ua.step_activity_id;

-- Conceder permissões
GRANT SELECT ON cc_view_user_activities TO authenticated;
