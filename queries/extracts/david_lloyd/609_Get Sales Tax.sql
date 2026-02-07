-- This is the version from 2026-02-05
--  
SELECT
    CASE
        WHEN vatt.scope_type = 'A'
        THEN a.name
        WHEN vatt.scope_type IN ('T'
                                 ,'G')
        THEN 'System'
        WHEN vatt.scope_type = 'C'
        THEN c.name
    END AS scope
    , vatt.name
    ,vatt.globalid
    , ROUND(vatt.rate,2)     AS rate
    ,ROUND(vatt.orig_rate,2) AS originalrate
    , vatt.external_id
FROM
    master_vat_types vatt
LEFT JOIN
    areas a
ON
    a.id =vatt.scope_id
AND vatt.scope_type = 'A'
LEFT JOIN
    centers c
ON
    c.id =vatt.scope_id
AND vatt.scope_type = 'C'