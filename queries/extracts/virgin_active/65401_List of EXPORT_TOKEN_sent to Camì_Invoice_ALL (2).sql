WITH
    params AS MATERIALIZED
    (
        SELECT
            dateToLongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'),'YYYY-MM-DD'), c.id) AS from_date,
            dateToLongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD'),'YYYY-MM-DD'), c.id) + 24*60*60*1000 AS to_date,
            c.id
        FROM
            centers c
    )
SELECT
    TO_CHAR(longtodate(inv.entry_time),' DD-MM-YYYY HH24:MI') "entry time" ,
    TO_CHAR(longtodate(inv.trans_time),' DD-MM-YYYY HH24:MI') "transaction time" ,
    ilm.total_amount ,
    inv.*
FROM
    invoice_lines_mt ilm
JOIN
    invoices inv
ON
    inv.id = ilm.id
AND inv.center = ilm.center
JOIN
    params par
ON
    par.id = inv.center
WHERE
    inv.entry_time > par.from_date
AND inv.entry_time < par.to_date