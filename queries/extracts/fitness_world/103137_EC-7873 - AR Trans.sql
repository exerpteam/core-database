-- This is the version from 2026-02-05
--  
SELECT DISTINCT
art.center AS "Center",
art.subid AS "#",
TO_CHAR(longtodateC(art.trans_time, art.center), 'dd-MM-YYYY') AS "Transaktionsdato",
art.amount AS "Beløb",
art.text AS "Tekst",
TO_CHAR(longtodateC(art.entry_time, art.center), 'dd-MM-YYYY') AS "Registreringsdato",
art.status AS "Status"
FROM
account_receivables ar
JOIN
fw.ar_trans art
ON
art.center = ar.center
AND art.id = ar.id
WHERE
ar.customercenter ||'p'|| ar.customerid IN (:memberid) 
ORDER BY
art.subid 