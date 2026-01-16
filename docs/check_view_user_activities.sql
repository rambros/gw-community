-- Verificar a definição da view cc_view_user_activities
SELECT
  schemaname,
  viewname,
  viewowner,
  definition
FROM pg_views
WHERE viewname = 'cc_view_user_activities';

-- Ver alguns exemplos de dados da view
SELECT
  id,
  user_step_id,
  step_activity_id,
  activity_label,
  activity_type,
  activity_status
FROM cc_view_user_activities
LIMIT 10;

-- Verificar se step_activity_id está populado
SELECT
  COUNT(*) as total,
  COUNT(step_activity_id) as with_step_activity_id,
  COUNT(*) - COUNT(step_activity_id) as without_step_activity_id
FROM cc_view_user_activities;
