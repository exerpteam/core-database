SELECT
    *
FROM
    (
        SELECT
            summed.ENTRY_TIME,
            summed.TEXT,
            summed.DUE_DATE,
            summed.TRANS_TYPE,
            summed.REF_TYPE,
            summed.BALANCE,
            summed.AMOUNT,
            summed.REQUEST_REF,
            CASE
                WHEN
                    (
                        SELECT
                            MAX(art.subid)
                        FROM
                            AR_TRANS art
                        WHERE
                            art.PAYREQ_SPEC_CENTER = summed.PAYREQ_SPEC_CENTER
                            AND art.PAYREQ_SPEC_ID = summed.PAYREQ_SPEC_ID
                            AND art.PAYREQ_SPEC_SUBID = summed.PAYREQ_SPEC_SUBID
                            AND art.COLLECTED != 2
                    )
                    != summed.subid
                THEN ''
                WHEN summed.REQUESTED_AMOUNT = summed.BALANCE
                THEN 'BALANCE POLICY'
                WHEN summed.REQUESTED_AMOUNT = summed.INVOICE_POLICY_AMOUNT
                THEN 'INVOICE POLICY'
                ELSE 'NO POLICY MATCH'
            END AS POLICY_USED,
            NULL REQUESTED_AMOUNT,
            summed.INVOICE_POLICY_AMOUNT
        FROM
            (
                SELECT
                    TO_CHAR(longToDate(art.ENTRY_TIME),'YYYY-MM-DD HH24:MM') entry_time,
                    art.SUBID,
                    art.PAYREQ_SPEC_CENTER,
                    art.PAYREQ_SPEC_ID,
                    art.PAYREQ_SPEC_SUBID,
                    art.TEXT,
                    TO_CHAR(art.DUE_DATE,'YYYY-MM-DD') DUE_DATE,
                    DECODE(art.COLLECTED,0,'UNCOLLECTED',1,'COLLECTED',2,'PAYMENT','UNDEFINED') TRANS_TYPE,
                    art.REF_TYPE,
                    (
                        SELECT
                            SUM(art2.AMOUNT)
                        FROM
                            AR_TRANS art2
                        WHERE
                            art2.CENTER = art.CENTER
                            AND art2.id = art.id
                            AND art2.SUBID <= art.SUBID
                    )
                    balance,
                    art.AMOUNT,
                    prs.REF REQUEST_REF,
                    prs.REQUESTED_AMOUNT * -1 REQUESTED_AMOUNT,
                    (
                        SELECT
                            SUM(art2.AMOUNT)
                        FROM
                            AR_TRANS art2
                        WHERE
                            art2.PAYREQ_SPEC_CENTER = art.PAYREQ_SPEC_CENTER
                            AND art2.PAYREQ_SPEC_ID = art.PAYREQ_SPEC_ID
                            AND art2.PAYREQ_SPEC_SUBID = art.PAYREQ_SPEC_SUBID
                            AND art2.REF_TYPE != 'ACCOUNT_TRANS'
                    )
                    invoice_policy_amount
                FROM
                    ACCOUNT_RECEIVABLES ar
                JOIN AR_TRANS art
                ON
                    art.CENTER = ar.CENTER
                    AND art.id = ar.id
                JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
                ON
                    prs.CENTER = art.PAYREQ_SPEC_CENTER
                    AND prs.ID = art.PAYREQ_SPEC_ID
                    AND prs.SUBID = art.PAYREQ_SPEC_SUBID
                WHERE
                    ar.CUSTOMERCENTER = :customer_center
                    AND ar.CUSTOMERID = :customer_id
                    AND ar.AR_TYPE = 4
                ORDER BY
                    art.ENTRY_TIME DESC
            )
            summed
        UNION
        SELECT DISTINCT
            TO_CHAR(longToDate(prs.ENTRY_TIME),'YYYY-MM-DD HH24:MM') entry_time,
            '***** PAYMENT REQUEST *****',
            TO_CHAR(prs.DUE_DATE,'YYYY-MM-DD') DUE_DATE,
            NULL,
            NULL,
            NULL,
            NULL,
            prs.REF,
            NULL,
            prs.REQUESTED_AMOUNT,
            prs.TOTAL_INVOICE_AMOUNT
        FROM
            ACCOUNT_RECEIVABLES ar
        JOIN AR_TRANS art
        ON
            art.CENTER = ar.CENTER
            AND art.id = ar.id
        JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            prs.CENTER = art.PAYREQ_SPEC_CENTER
            AND prs.ID = art.PAYREQ_SPEC_ID
            AND prs.SUBID = art.PAYREQ_SPEC_SUBID
        WHERE
            ar.CUSTOMERCENTER = :customer_center
            AND ar.CUSTOMERID = :customer_id
            AND ar.AR_TYPE = 4
    )
ORDER BY
    1 DESC