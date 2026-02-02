-- Verificar se RLS está habilitado em cc_step_activities
SELECT
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE tablename = 'cc_step_activities';

-- Ver as policies RLS existentes em cc_step_activities
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'cc_step_activities';
