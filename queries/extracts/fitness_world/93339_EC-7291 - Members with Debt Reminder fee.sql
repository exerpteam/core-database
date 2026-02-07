-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST(datetolong(TO_CHAR(TO_DATE((:from_date), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS bigint)
            AS fromdate,
            CAST(datetolong(TO_CHAR(TO_DATE((:to_date), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS bigint)
            +86400000 AS todate,
            c.ID      AS CenterID
        FROM
            CENTERS c
    )
SELECT
    p.center ||'p'|| p.id                             AS "P number",
    p.external_id                                     AS "External ID",
    TO_CHAR(longtodate(art.trans_time), 'dd-MM-YYYY') AS "Entry Date",
    art.text                                          AS "Text",
    art.amount                                        AS "Amount",
    art.unsettled_amount                              AS "Open Amount"                             
FROM
    persons p
JOIN
    account_receivables ar
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
AND ar.ar_type = 4
JOIN
    ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
JOIN
    invoice_lines_mt invl
ON
    invl.center = art.ref_center
AND invl.id = art.ref_id
AND art.ref_type = 'INVOICE'
JOIN
    products pr
ON
    pr.center = invl.productcenter
AND pr.id = invl.productid
AND pr.globalid IN ('RYKKER_1',
                    'RYKKER_2')
JOIN
    params
ON
    params.centerid = p.center
WHERE
    art.trans_time BETWEEN params.fromdate AND params.todate
	AND p.center in (:scope)