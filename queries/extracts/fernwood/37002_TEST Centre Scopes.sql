-- The extract is extracted from Exerp on 2026-02-08
-- 
SELECT column_name 
FROM information_schema.columns 
WHERE table_schema = 'fernwood' 
AND table_name = 'centers'
ORDER BY column_name;