-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    e.NAME,
    longToDate(MAX(eu.TIME)) used,
    COUNT(e.ID)
FROM
    EXTRACT_USAGE eu
JOIN EXTRACT e
ON
    e.ID = eu.EXTRACT_ID
WHERE
    e.BLOCKED = 0
GROUP BY
    e.NAME
ORDER BY
    COUNT(e.ID) ASC 