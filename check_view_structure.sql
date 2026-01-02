-- Ver a definição completa da view
SELECT
  schemaname,
  viewname,
  definition
FROM pg_views
WHERE viewname = 'cc_view_user_activities';

-- Ver as colunas disponíveis na view
SELECT
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'cc_view_user_activities'
ORDER BY ordinal_position;
