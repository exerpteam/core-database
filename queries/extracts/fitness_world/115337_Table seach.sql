-- This is the version from 2026-02-05
--  
SELECT attname AS column_name
FROM pg_attribute
WHERE attrelid = 'fw.MESSAGES'::regclass
  AND attnum > 0
  AND NOT attisdropped;
