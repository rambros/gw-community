-- Ver a estrutura da tabela cc_user_activities
SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'cc_user_activities'
ORDER BY ordinal_position;

-- Ver um exemplo de dados
SELECT *
FROM cc_user_activities
LIMIT 3;
