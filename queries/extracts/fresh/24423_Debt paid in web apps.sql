-- The extract is extracted from Exerp on 2026-02-08
-- DEV-51611
WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE(:fromdate,'YYYY-MM-DD'),'YYYY-MM-DD'), c.id) AS BIGINT) AS fromDate,
            CAST(datetolongC(TO_CHAR(TO_DATE(:todate,'YYYY-MM-DD') + interval '1 days','YYYY-MM-DD'),
            c.id) AS BIGINT) AS toDate,
            c.id  AS center_id
        FROM
            centers c
    )
SELECT
    p.external_id                           AS "External ID",
    p.center||'p'||p.id                     AS "Person ID",
    longtodateC(art.entry_time, art.center) AS "Transaction Time",
    art.text                                AS "Text",
    art.amount                              AS "Amount"
FROM
    ar_trans art
JOIN
    params
ON
    params.center_id = art.center
JOIN
    account_receivables ar
ON
    art.center = ar.center
AND art.id = ar.id
JOIN
    persons p
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
WHERE
    art.employeecenter = 200
AND art.employeeid = 28404
AND art.trans_time BETWEEN params.fromDate AND params.toDate
AND (art.text LIKE 'Manuell betalingsregistrering%' OR art.text LIKE 'API Register remaining money from payment request%')