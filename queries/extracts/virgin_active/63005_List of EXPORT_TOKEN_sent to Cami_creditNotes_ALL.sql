-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
  TO_CHAR(longtodate(inv.entry_time),' DD-MM-YYYY HH24:MI') "entry time" ,  TO_CHAR(longtodate(inv.trans_time),' DD-MM-YYYY HH24:MI') "transaction time" , ilm.total_amount , inv.*
FROM
    CREDIT_NOTE_lines_mt ilm
JOIN
    CREDIT_NOTES inv
ON
    inv.id = ilm.id
AND inv.center = ilm.center
join centers cen on cen.id= inv.center
WHERE
--inv.FISCAL_REFERENCE IS NOT NULL
cen.country='IT'
AND inv.entry_time > :FromDate
AND inv.entry_time < :ToDate + 24*60*60*1000