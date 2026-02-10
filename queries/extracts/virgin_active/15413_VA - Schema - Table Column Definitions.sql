-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT *
--FROM user_tab_cols
FROM information_schema.columns
WHERE table_name = $$table_name$$