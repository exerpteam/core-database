-- This is the version from 2026-02-05
-- https://clublead.atlassian.net/browse/ST-4390
WITH params AS (
    SELECT 
        -- Assuming exerpsysdate() is a custom function in your DB, replace it if necessary.
        (DATE_TRUNC('day', CURRENT_TIMESTAMP - INTERVAL ':offset days') AT TIME ZONE 'Europe/Copenhagen') AS FromDate
)
SELECT 
   cr.Center AS "Club ID",
   cr.NAME   AS "Vending Name",
   count(crt.CENTER)  AS "Threshold"
FROM 
   params
CROSS JOIN
   CASHREGISTERS cr
LEFT JOIN
   CASHREGISTERTRANSACTIONS crt
ON 
   crt.CRCENTER = cr.CENTER
   AND crt.ID = cr.ID   
   AND crt.TRANSTIME >= params.FromDate
WHERE
   cr.center IN (:Scope)
   AND cr.TYPE = 'VENDING'
GROUP BY
   cr.Center, cr.Name
HAVING count(crt.CENTER) < 10
ORDER BY cr.Center;
