WITH
    params AS
    (
        SELECT
            /*+ materialize */
            CAST(datetolongC(TO_CHAR(CAST(:from_datetime AS timestamp), 'YYYY-MM-DD HH12:MI AM'), c.id) AS BIGINT) AS from_date,
            CAST(datetolongC(TO_CHAR(CAST(:to_datetime AS timestamp), 'YYYY-MM-DD HH12:MI AM'), c.id) AS BIGINT) AS to_date,
            c.id             AS center_id
        FROM
            CENTERS c
    )
SELECT
crt.center,
crt.id,
crt.subid,
TO_CHAR(longtodateC(crt.transtime, crt.center), 'YYYY-MM-dd HH12:MI:ss AM') AS transaction_time,
p.external_id AS member_id,
'COMO' AS payment_method,
crt.amount AS payment_amount,
pr.globalid
FROM
cashregistertransactions crt
JOIN
params
ON
params.center_id = crt.center
JOIN
persons p
ON
p.center = crt.customercenter
AND p.id = crt.customerid
JOIN
    invoices inv
ON
    crt.paysessionid = inv.paysessionid
JOIN
    villageurban.invoice_lines_mt invl
    ON
    invl.center = inv.center
    AND invl.id = inv.id
JOIN
    products pr
    ON
    pr.center = invl.productcenter
    AND pr.id = invl.productid
WHERE
crt.crttype = 13
AND crt.config_payment_method_id = 9
AND crt.transtime BETWEEN params.from_date AND params.to_date
AND p.center IN (:scope)