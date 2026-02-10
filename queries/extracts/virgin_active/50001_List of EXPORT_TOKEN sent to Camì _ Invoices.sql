-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
   TO_CHAR(longtodate(inv.entry_time),' DD-MM-YYYY HH24:MI') "entry time" , TO_CHAR(longtodate(inv.trans_time),' DD-MM-YYYY HH24:MI') "transaction time" , ilm.total_amount , inv.*
FROM
    invoice_LINES_MT ilm
JOIN
    invoices inv
ON
    inv.id = ilm.id
AND inv.center = ilm.center
join centers cen on cen.id= inv.center
WHERE
inv.FISCAL_REFERENCE IS NOT NULL
AND cen.country='IT'
AND inv.entry_time > :FromDate
AND inv.entry_time < :ToDate + 24*60*60*1000