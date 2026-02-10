-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT attname AS column_name
FROM pg_attribute
WHERE attrelid = 'fw.MESSAGES'::regclass
  AND attnum > 0
  AND NOT attisdropped;
