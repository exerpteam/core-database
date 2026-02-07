-- This is the version from 2026-02-05
--  
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'products' AND table_schema = 'fw'
ORDER BY column_name;