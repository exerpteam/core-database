WITH
    params AS MATERIALIZED
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(TO_DATE(:fromdate,'YYYY-MM-DD'),'YYYY-MM-DD'), c.id) AS BIGINT
            ) AS fromDate,
            CAST(dateToLongC(TO_CHAR(TO_DATE(:todate,'YYYY-MM-DD'),'YYYY-MM-DD'), c.id) AS BIGINT)
            + 86400000 AS toDate,
            c.id       AS center_id
        FROM
            centers c
    )
SELECT
    com.center ||'p'|| com.id                                    AS "Company ID",
    com.fullname                                                 AS "Company Name",
    pr.name                                                      AS "Product Name",
    longtodateC(art.entry_time, com.center)                      AS "Entry time",
    invl.total_amount                                            AS "Amount",
    emp.fullname                                                 AS "Sales Employee",
    cn.center ||'cred'|| cn.id                                   AS "Credit Note ID",
    TO_CHAR(longtodateC(cn.entry_time, com.center),'dd-mm-yyyy') AS "Credit Note Time"
FROM
    persons com
JOIN
    params par
ON
    par.center_id = com.center
JOIN
    sats.account_receivables ar
ON
    ar.customercenter = com.center
AND ar.customerid = com.id
AND ar.ar_type = 4
JOIN
    sats.ar_trans art
ON
    art.center = ar.center
AND art.id = ar.id
JOIN
    sats.invoices inv
ON
    inv.center = art.ref_center
AND inv.id = art.ref_id
AND art.ref_type = 'INVOICE'
JOIN
    sats.invoice_lines_mt invl
ON
    invl.center = inv.center
AND invl.id = inv.id
JOIN
    products pr
ON
    pr.center = invl.productcenter
AND pr.id = invl.productid
JOIN
    employees empl
ON
    empl.center = inv.employee_center
AND empl.id = inv.employee_id
JOIN
    persons emp
ON
    emp.center = empl.personcenter
AND emp.id = empl.personid
LEFT JOIN
    sats.credit_notes cn
ON
    cn.invoice_center = inv.center
AND cn.invoice_id = inv.id
WHERE
    com.sex = 'C'
AND art.entry_time BETWEEN par.fromDate AND par.toDate
AND com.center IN (:scope)
AND pr.ptype IN (1,2,4)