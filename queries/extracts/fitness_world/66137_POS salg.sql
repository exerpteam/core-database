-- This is the version from 2026-02-05
--  
select
count(*) AS transactions_count,
--cr.CENTER
TO_CHAR(longtodate(crt.TRANSTIME), 'DD-MM-YYYY') as "DATE"
from CASHREGISTERS cr
LEFT JOIN
   CASHREGISTERTRANSACTIONS crt
ON 
   crt.CRCENTER = cr.CENTER
   AND crt.ID = cr.ID
WHERE
cr.CENTER in (:scope) 
AND cr.TYPE = 'POS'
--AND cr.BLOCKED = 0
AND crt.TRANSTIME >= 1546297200000
AND crt.TRANSTIME < 1577833200000
GROUP BY
TO_CHAR(longtodate(crt.TRANSTIME), 'DD-MM-YYYY')
ORDER BY 1 DESC