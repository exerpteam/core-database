-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-7768
SELECT
    e.NAME                                              AS "Extract name",
    CASE WHEN e.SCOPE_TYPE = 'A' THEN a.NAME 
         WHEN e.SCOPE_TYPE = 'C' THEN c.NAME
         ELSE 'System'
    END                                                 AS "Scope" ,
    to_char(longtodate(max(eu.TIME)),'DD-MM-YYYY')      AS "Last used date",
    COUNT(eu.ID)                                        AS "Number of uses"
FROM
    extract e
LEFT JOIN
    areas a
ON
    e.SCOPE_ID = a.id and e.SCOPE_TYPE = 'A'
LEFT JOIN
    centers c
ON 
    e.SCOPE_ID = c.id and e.SCOPE_TYPE = 'C'
LEFT JOIN
    EXTRACT_USAGE eu
ON
    e.ID = eu.EXTRACT_ID
GROUP BY 
    e.NAME, e.SCOPE_TYPE, a.NAME, c.NAME