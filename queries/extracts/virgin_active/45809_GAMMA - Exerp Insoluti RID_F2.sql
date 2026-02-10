-- The extract is extracted from Exerp on 2026-02-08
-- extract finance #5
WITH
    PARAMS AS MATERIALIZED
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
    CONCAT(CONCAT(CAST(p1.CENTER AS CHAR(3)),'p'), CAST(p1.ID AS VARCHAR(8))) AS "PERSONID" ,
    CASE
        WHEN pr.CLEARINGHOUSE_ID IN (803,
                                     2801,
                                     2802,
                                     2803,
                                     2804)
        THEN '99'
        ELSE '02'
    END             AS "PAYMENT_METHOD" ,
    par.EXTERNAL_ID AS "EXTERNAL_ID" ,
    agr.TEXT        AS "TEXT" ,
    CASE
        WHEN art3.ID IS NULL
        THEN prs.OPEN_AMOUNT
        ELSE art3.AMOUNT
    END                         AS "OPEN_AMOUNT" ,
    pr.REQ_DATE                 AS "DUE_DATE" ,
    longtodate(art1.ENTRY_TIME) AS "BOOK_DATE" ,
    vat.EXTERNAL_ID             AS "VAT_TYPE" ,
    vat.RATE                    AS "VAT_RATE"
FROM
    persons p1
JOIN
    params par
ON
    p1.center = par.center_id
    --     join centers c
    -- ON p1.center = c.id
    -- AND  c.COUNTRY ='IT'
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
    AR_TRANS art1
ON
    art1.PAYREQ_SPEC_SUBID = prs.SUBID
AND art1.PAYREQ_SPEC_ID = prs.ID
AND art1.PAYREQ_SPEC_CENTER = prs.CENTER
AND art1.DUE_DATE IS NOT NULL
AND art1.REF_TYPE = 'ACCOUNT_TRANS'
LEFT JOIN
    AR_TRANS ART2
ON
    Art1.CENTER = ART2.center
AND Art1.ID = ART2.ID
AND art1.PAYREQ_SPEC_SUBID = ART2.PAYREQ_SPEC_SUBID
AND art1.DUE_DATE IS NOT NULL
AND ART2.INFO IS NOT NULL
LEFT JOIN
    AR_TRANS ART3
ON
    Art2.CENTER = ART3.center
AND Art2.ID = ART3.ID
AND Art2.INFO = art3.INFO
AND art3.AMOUNT > 0
AND art3.TEXT LIKE 'Transfer to cash collection account%'
LEFT JOIN
    ACCOUNT_TRANS act
ON
    act.CENTER = art1.REF_CENTER
AND act.ID = art1.REF_ID
AND act.SUBID = art1.REF_SUBID
LEFT JOIN
    AGGREGATED_TRANSACTIONS agr
ON
    agr.CENTER = act.AGGREGATED_TRANSACTION_CENTER
AND agr.ID = act.AGGREGATED_TRANSACTION_ID
LEFT JOIN
    INVOICELINES invl
ON
    invl.ID = art.REF_ID
AND invl.CENTER = art.REF_CENTER
    --INNER JOIN
    --    CENTERS c
    --ON
    --    C.ID = PR.CENTER
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
    --WHERE
    --    c.country = 'IT'
    ---
    --  CROSS JOIN params par
    -- Remove, testing only!
WHERE
    Extract(MONTH FROM pr.REQ_DATE) = par.sel_month
AND Extract(YEAR FROM pr.REQ_DATE) = par.sel_year
AND CAST(extract(DAY FROM pr.req_date) AS INT) <= 4
AND pr.STATE IS NOT NULL
AND ART.REF_TYPE = 'INVOICE'
AND PR.STATE IN (3,
                 5,
                 12,
                 17)
AND (
        ART3.SUBID IS NOT NULL
    OR  OPEN_AMOUNT > 0 )
AND art1.ID IS NOT NULL
GROUP BY
    p1.CENTER ,
    P1.ID ,
    pr.CLEARINGHOUSE_ID ,
    CASE
        WHEN pr.CLEARINGHOUSE_ID IN (803,
                                     2801,
                                     2802,
                                     2803,
                                     2804)
        THEN '99'
        ELSE '02'
    END ,
    agr.TEXT ,
    pr.REQ_DATE ,
    longtodate(art1.ENTRY_TIME) ,
    vat.EXTERNAL_ID ,
    vat.RATE ,
    par.EXTERNAL_ID ,
    CASE
        WHEN art3.ID IS NULL
        THEN prs.OPEN_AMOUNT
        ELSE art3.AMOUNT
    END