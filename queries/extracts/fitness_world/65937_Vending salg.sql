-- The extract is extracted from Exerp on 2026-02-08
--  
select
count(*) as transactions_count,
--cr.CENTER
TO_CHAR(longtodate(crt.TRANSTIME), 'DD-MM-YYYY') AS "DATE"
from CASHREGISTERS cr
LEFT JOIN
   CASHREGISTERTRANSACTIONS crt
ON 
   crt.CRCENTER = cr.CENTER
   AND crt.ID = cr.ID
WHERE
cr.CENTER in (:scope) 
AND cr.TYPE = 'VENDING'
--AND cr.BLOCKED = 0
AND crt.TRANSTIME >= 1546297200000
AND crt.TRANSTIME < 1577833200000
GROUP BY
TO_CHAR(longtodate(crt.TRANSTIME), 'DD-MM-YYYY')
ORDER BY 1 DESC