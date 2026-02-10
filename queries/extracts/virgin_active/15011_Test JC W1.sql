-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    *
FROM
    extract e
WHERE
    convert_from(sql_query_blob, 'UTF-8') LIKE '%HH:MI%'