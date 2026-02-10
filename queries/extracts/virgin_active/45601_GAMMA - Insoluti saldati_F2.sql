-- The extract is extracted from Exerp on 2026-02-08
-- extract finance #9
WITH
    PARAMS AS NOT MATERIALIZED
    (
        SELECT
            EXTRACT(MONTH FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))     AS sel_month,
            EXTRACT(YEAR FROM ADD_MONTHS(CURRENT_TIMESTAMP,-1))      AS sel_year,
            TRUNC(CURRENT_DATE)                                      AS importdate,
            ADD_MONTHS(LAST_DAY(CAST(CURRENT_TIMESTAMP AS DATE)),-2) AS pr_req_date_param,
            c.id                                                     AS center_id,
            c.external_id
        FROM
            centers c
        WHERE
         
          c.country = 'IT'

    )

SELECT
    CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)), 'p'), CAST(p1.ID AS VARCHAR(8))) AS "PERSONID",
    CASE
        WHEN
            --pr.CLEARINGHOUSE_ID = 803 THEN '98'
            pr.CLEARINGHOUSE_ID IN (803,
                                    2801,
                                    2802,
                                    2803,
                                    2804)
        THEN '98'
        ELSE '02'
    END           AS "PAYMENT_METHOD",
    c.EXTERNAL_ID AS "EXTERNAL_ID",
    CASE
        WHEN prs.OPEN_AMOUNT > 0
        THEN prs.REQUESTED_AMOUNT - prs.OPEN_AMOUNT
        ELSE prs.REQUESTED_AMOUNT
    END                            AS "AMOUNT",
    pr.REQ_DATE                    AS "SCADENZA",
    vat.EXTERNAL_ID                AS "EXTERNAL_ID",
    vat.RATE                       AS "RATE",
    TRUNC(CURRENT_TIMESTAMP) AS "IMPORTDATE"
FROM
    PERSONS p1
    
    JOIN
    params par
ON
    p1.center = par.center_id
JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p1.CENTER
AND ar.CUSTOMERID = p1.ID
AND ar.AR_TYPE = 4
LEFT JOIN
    PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
AND pac.ID = ar.ID
LEFT JOIN
    PAYMENT_REQUESTS pr
ON
    pr.CENTER = ar.CENTER
AND pr.ID = ar.id
LEFT JOIN
    PAYMENT_REQUEST_SPECIFICATIONS prs
ON
    pr.INV_COLL_CENTER = prs.CENTER
AND pr.INV_COLL_ID = prs.ID
AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN
    AR_TRANS art
ON
    art.PAYREQ_SPEC_SUBID = prs.SUBID
AND art.PAYREQ_SPEC_ID = prs.ID
AND art.PAYREQ_SPEC_CENTER = prs.CENTER
LEFT JOIN
    AR_TRANS ART3
ON
    Art.CENTER = ART3.center
AND Art.ID = ART3.ID
AND art3.SUBID > art.SUBID
AND art3.AMOUNT > 0
AND art3.TEXT NOT LIKE 'Automatic%'
AND art3.TEXT NOT LIKE 'Transfer to%'
AND art3.REF_TYPE = 'ACCOUNT_TRANS'
LEFT JOIN
    INVOICELINES invl
ON
    invl.ID = art.REF_ID
AND invl.CENTER = art.REF_CENTER
INNER JOIN
    CENTERS c
ON
    C.ID = PR.CENTER
LEFT JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = art3.REF_CENTER
AND act.ID = art3.REF_ID
AND act.SUBID = art3.REF_SUBID
LEFT JOIN
    AGGREGATED_TRANSACTIONS agr
ON
    agr.CENTER = act.AGGREGATED_TRANSACTION_CENTER
AND agr.ID = act.AGGREGATED_TRANSACTION_ID
LEFT JOIN
    ACCOUNT_TRANS act1
ON
    act1.CENTER = invl.VAT_ACC_TRANS_CENTER
AND act1.ID = invl.VAT_ACC_TRANS_ID
AND act1.SUBID = invl.VAT_ACC_TRANS_SUBID
LEFT JOIN
    VAT_TYPES vat
ON
    vat.CENTER = act1.VAT_TYPE_CENTER
AND vat.ID = act1.VAT_TYPE_ID
--LEFT JOIN
--    CENTERS c2
--ON
--    c2.ID = P1.CENTER
WHERE

    --pr.center = 102
 ((
            pr.req_date > TO_DATE('30/09/2016', 'dd/mm/YYYY')
            --AND pr.CLEARINGHOUSE_ID != 803)
        AND pr.CLEARINGHOUSE_ID NOT IN (803,
                                        2801,
                                        2802,
                                        2803,
                                        2804))
    OR
        --(pr.CLEARINGHOUSE_ID = 803
        (
            pr.CLEARINGHOUSE_ID IN (803,
                                    2801,
                                    2802,
                                    2803,
                                    2804)
        AND pr.req_date > TO_DATE('31/12/2016', 'dd/mm/YYYY')))
AND pr.req_date <= ADD_MONTHS(LAST_DAY(CURRENT_DATE), -2)
AND CAST(extract(DAY FROM pr.req_date) AS INT) <= 4
    --and art1.PAYREQ_SPEC_CENTER = select c.ID from CENTERS c where  c.COUNTRY = 'IT' and
    -- art1.PAYREQ_SPEC_ID = 21020  and art1.PAYREQ_SPEC_SUBID = 2
AND Extract(MONTH FROM (longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = par.sel_month
AND Extract(YEAR FROM (longtodate(prs.PAID_STATE_LAST_ENTRY_TIME))) = par.sel_year
AND Extract(MONTH FROM (longtodate(art3.ENTRY_TIME))) = par.sel_month
AND Extract(YEAR FROM (longtodate(art3.ENTRY_TIME))) = par.sel_year
AND pr.STATE IS NOT NULL
AND ART.REF_TYPE = 'INVOICE'
AND OPEN_AMOUNT < REQUESTED_AMOUNT
GROUP BY
    p1.center,
    p1.id,
    prs.OPEN_AMOUNT,
    prs.REQUESTED_AMOUNT,
    --pr.CLEARINGHOUSE_ID,
    CASE
        WHEN
            --pr.CLEARINGHOUSE_ID = 803 THEN '98'
            pr.CLEARINGHOUSE_ID IN (803,
                                    2801,
                                    2802,
                                    2803,
                                    2804)
        THEN '98'
        ELSE '02'
    END,
    c.EXTERNAL_ID,
    prs.OPEN_AMOUNT,
    pr.REQ_DATE,
    prs.LAST_MODIFIED,
    vat.EXTERNAL_ID,
    vat.RATE