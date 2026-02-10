-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'products' AND table_schema = 'fw'
ORDER BY column_name;