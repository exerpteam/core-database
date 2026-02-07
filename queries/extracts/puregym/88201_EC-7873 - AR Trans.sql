SELECT DISTINCT
	art.center AS "Center",
	art.subid AS "#",
	TO_CHAR(longtodateC(art.trans_time, art.center), 'dd-MM-YYYY') AS "Transaction date",
	art.amount AS "Amount",
        art.text AS "Text",
        TO_CHAR(longtodateC(art.entry_time, art.center), 'dd-MM-YYYY') AS "Date of registration",
        art.status AS "Status"
FROM account_receivables ar
JOIN ar_trans art
        ON art.center = ar.center
        AND art.id = ar.id
WHERE
        (ar.customercenter,ar.customerid) IN (:memberid) 
ORDER BY
        art.subid