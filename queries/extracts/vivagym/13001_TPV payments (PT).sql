-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS materialized
    (
        SELECT
            CAST(datetolongC(TO_CHAR(TO_DATE((:fromdate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT) AS fromdate,
            CAST(datetolongC(TO_CHAR(TO_DATE((:todate), 'YYYY-MM-DD'), 'YYYY-MM-DD'), c.id) AS
            BIGINT)+86400000-1 AS todate,
            c.id               AS centerid
        FROM
            centers c
    )
SELECT
    TO_CHAR(longtodateC(cct.transtime, cct.center), 'DD-MM-YYYY HH24:MI') AS "Payment Date",
    curr_p.external_id                                                    AS "Member External ID",
    CASE
        WHEN inv2.center IS NOT NULL
        THEN inv2.center ||'inv'|| inv2.id
        WHEN inv3.center IS NOT NULL
        THEN inv3.center ||'inv'|| inv3.id
        WHEN inv4.center IS NOT NULL
        THEN inv4.center ||'inv'|| inv4.id
        ELSE inv.center ||'inv'|| inv.id
    END        AS "Exerp Invoice Number",
    cct.amount AS "Transaction Amount",
    CASE
        WHEN arm.amount IS NOT NULL
        THEN arm.amount
        WHEN arm2.amount IS NOT NULL
        THEN arm2.amount
        WHEN arm3.amount IS NOT NULL
        THEN arm3.amount
        ELSE cct.amount
    END                AS "Invoice Settled Amount",
    cct.transaction_id AS "PSP Reference",
    cct.order_id       AS "Merchant Reference"
FROM
    creditcardtransactions cct
JOIN
    cashregistertransactions crt
ON
    crt.gltranscenter = cct.gl_trans_center
AND crt.gltransid = cct.gl_trans_id
AND crt.gltranssubid = cct.gl_trans_subid
JOIN
    params
ON
    params.centerid = crt.center
LEFT JOIN
    invoices inv
ON
    crt.paysessionid = inv.paysessionid
LEFT JOIN
    crt_art_link artcrt_link
ON
    artcrt_link.crt_center = crt.center
AND artcrt_link.crt_id = crt.id
AND artcrt_link.crt_subid = crt.subid
LEFT JOIN
    ar_trans pay
ON
    pay.center = artcrt_link.art_center
AND pay.id = artcrt_link.art_id
AND pay.subid = artcrt_link.art_subid
LEFT JOIN
    art_match arm
ON
    arm.art_paying_center = pay.center
AND arm.art_paying_id = pay.id
AND arm.art_paying_subid = pay.subid
LEFT JOIN
    ar_trans invo
ON
    invo.center = arm.art_paid_center
AND invo.id = arm.art_paid_id
AND invo.subid = arm.art_paid_subid
LEFT JOIN
    invoices inv2
ON
    inv2.center = invo.ref_center
AND inv2.id = invo.ref_id
AND invo.ref_type = 'INVOICE'
LEFT JOIN
    ar_trans art
ON
    art.center = crt.artranscenter
AND art.id = crt.artransid
AND art.subid = crt.artranssubid
LEFT JOIN
    art_match arm2
ON
    arm2.art_paying_center = art.center
AND arm2.art_paying_id = art.id
AND arm2.art_paying_subid = art.subid
LEFT JOIN
    ar_trans invo2
ON
    invo2.center = arm2.art_paid_center
AND invo2.id = arm2.art_paid_id
AND invo2.subid = arm2.art_paid_subid
LEFT JOIN
    invoices inv3
ON
    inv3.center = invo2.ref_center
AND inv3.id = invo2.ref_id
AND invo2.ref_type = 'INVOICE'
LEFT JOIN
ar_trans art2
ON
art2.ref_center = invo2.ref_center
AND art2.ref_id = invo2.ref_id
AND art2.ref_subid = invo2.ref_subid
AND art2.ref_type = 'ACCOUNT_TRANS'
AND (invo2.center,invo2.id) != (art2.center,art2.id)
LEFT JOIN
art_match arm3
ON
    arm3.art_paying_center = art2.center
AND arm3.art_paying_id = art2.id
AND arm3.art_paying_subid = art2.subid

LEFT JOIN
    ar_trans invo3
ON
    invo3.center = arm3.art_paid_center
AND invo3.id = arm3.art_paid_id
AND invo3.subid = arm3.art_paid_subid
LEFT JOIN
    invoices inv4
ON
    inv4.center = invo3.ref_center
AND inv4.id = invo3.ref_id
AND invo3.ref_type = 'INVOICE'

LEFT JOIN
    persons p
ON
    p.center = crt.customercenter
AND p.id = crt.customerid
LEFT JOIN
    persons curr_p
ON
    curr_p.center = p.current_person_center
AND curr_p.id = p.current_person_id
WHERE
    cct.transtime BETWEEN params.fromdate AND params.todate
    AND crt.center IN (:scope)
ORDER BY
    cct.transtime