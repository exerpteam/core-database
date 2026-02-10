-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:fromDate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS fromDate,
            CAST(datetolongC(TO_CHAR(TO_DATE((:toDate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) +86400000 AS toDate,
            c.id              AS centerid
        FROM
            centers c
    )
SELECT
    longtodateC(crt.transtime, crt.center)      AS "Transaction Time",
    crt.customercenter ||'p'|| crt.customerid   AS "Member ID",
    crt.amount                                  AS "Amount",
    crt.coment                                  AS "Comment",
    crt.employeecenter ||'emp'|| crt.employeeid AS "Sales Employee",
    CASE
        WHEN crt.artranscenter IS NULL
        THEN 'Invoice'
        ELSE 'Payment into account'
    END                                                                       AS "Payment Type",
	1513 										AS "Konto",
    act.aggregated_transaction_center ||'agt'|| act.aggregated_transaction_id AS "Agt"
FROM
    cashregistertransactions crt
JOIN
    params par
ON
    par.centerid = crt.center
LEFT JOIN
    sats.account_trans act
ON
    act.center = crt.gltranscenter
AND act.id = crt.gltransid
AND act.subid = crt.gltranssubid
WHERE
    crt.crttype = 13
AND crt.config_payment_method_id = 9
AND crt.transtime BETWEEN par.fromDate AND par.toDate
    AND crt.center IN (:scope)
ORDER BY
    crt.transtime DESC