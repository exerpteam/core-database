-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    *
FROM
    (
        SELECT
            p.CENTER || 'p' || p.ID pid,
            pr.REF,
            pr.SUBID,
            pr.REQ_DATE,
            pr.REQ_AMOUNT,
            prs.REQUESTED_AMOUNT,
            SUM(
                CASE
                    WHEN art.REF_TYPE IN ('INVOICE',
                                          'CREDIT_NOTE')
                    THEN art.AMOUNT
                    ELSE 0
                END)                                                                                                                                                                    AS invoice_policy,
            SUM(art.COLLECTED_AMOUNT)                                                                                                                                                      open_amount
        FROM
            PAYMENT_REQUEST_SPECIFICATIONS prs
        JOIN
            PAYMENT_REQUESTS pr
        ON
            pr.INV_COLL_CENTER = prs.CENTER
            AND pr.INV_COLL_ID = prs.ID
            AND pr.INV_COLL_SUBID = prs.SUBID
        JOIN
            AR_TRANS art
        ON
            art.PAYREQ_SPEC_CENTER = prs.CENTER
            AND art.PAYREQ_SPEC_ID = prs.ID
            AND art.PAYREQ_SPEC_SUBID = prs.SUBID
            AND art.COLLECTED = 1
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
            AND ar.AR_TYPE = 4
        JOIN
            PERSONS p
        ON
            p.CENTER = ar.CUSTOMERCENTER
            AND p.ID = ar.CUSTOMERID
            AND p.SEX = 'C'
            --AND p.CENTER = 500
            --AND p.ID = 129251
            
            AND pr.SUBID IN
            (
                SELECT
                    MAX(pr2.subid)
                FROM
                    PAYMENT_REQUESTS pr2
                WHERE
                    pr2.CENTER = pr.CENTER
                    AND pr2.ID = pr.ID )
        GROUP BY
            p.CENTER ,
            p.ID ,
            pr.REF,
            pr.SUBID,
            pr.REQ_DATE,
            pr.REQ_AMOUNT,
            prs.REQUESTED_AMOUNT) i1
WHERE
    i1.INVOICE_POLICY != i1.OPEN_AMOUNT