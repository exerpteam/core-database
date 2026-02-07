SELECT
   TO_CHAR(longtodate(inv.trans_time),' DD-MM-YYYY HH24:MI') "transaction time" , ilm.total_amount , inv.*
FROM
    invoice_lines_mt ilm
JOIN
    invoices inv
ON
    inv.id = ilm.id
AND inv.center = ilm.center
WHERE
inv.FISCAL_REFERENCE IS NOT NULL
AND inv.CENTER in ($$center$$)
AND inv.trans_time > :FromDate
AND inv.trans_time < :ToDate + 24*60*60*1000