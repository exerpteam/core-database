SELECT *
--FROM user_tab_cols
FROM information_schema.columns
WHERE table_name = $$table_name$$