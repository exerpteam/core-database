WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST (dateToLongC(TO_CHAR(CAST($$fromDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                  AS FromDate,
            CAST((dateToLongC(TO_CHAR(CAST($$toDate$$ AS DATE), 'YYYY-MM-dd HH24:MI'), c.id)+ 86400 * 1000)-1 AS BIGINT) AS ToDate
        FROM
            centers c
    )
SELECT
    /*+ NO_BIND_AWARE */
    (
        SELECT
            c.EXTERNAL_ID
        FROM
            centers c
        WHERE
            c.id = center) AS CostCenter,
    (
        SELECT
            c.name
        FROM
            centers c
        WHERE
            c.id = center) AS Site,
    type,
    account,
    TRANS_TYPE,
    text,
    SUM(VAT)    AS VAT,
    SUM( TOTAL) AS TOTAL
FROM
    (
        SELECT
            art.center,
            acc.name AS account,
            CASE
                WHEN (art.amount > 0)
                THEN 'PAYMENT'
                ELSE 'REFUND'
            END           AS type,
            art2.ref_type AS TRANS_TYPE,
            CASE
                WHEN (il.center IS NOT NULL )
                THEN
                    CASE
                        WHEN POSITION(':' IN il.text) > 0
                        THEN SUBSTR(il.text,1,POSITION(':' IN il.text)-1)
                        ELSE il.text
                    END
                WHEN (cl.center IS NOT NULL )
                THEN
                    CASE
                        WHEN POSITION(':' IN cl.text) > 0
                        THEN SUBSTR(cl.text,1,POSITION(':' IN cl.text)-1)
                        ELSE cl.text
                    END
                ELSE
                    CASE
                        WHEN (art2.text LIKE 'Deduction 20%')
                        THEN 'Converted Harlands'
                            -- WHEN (acc.name LIKE 'Debt to %')
                            --THEN 'Cross center'
                        WHEN (acc2.name IS NOT NULL)
                        THEN acc2.name
                        ELSE art2.text
                    END
            END AS text,
            CASE
                    --when art2.amount = 0 then 0
                WHEN (il.center IS NOT NULL )
                THEN
                    CASE
                        WHEN (am.amount = art2.amount)
                        THEN vat.amount
                            -- in the case the amount is a match for only part of the
                            -- invoice line,
                            -- we need to make it proportianal
                        ELSE ROUND(am.amount*vat.amount/ABS(art2.amount),2)
                    END
                WHEN (cl.center IS NOT NULL )
                THEN
                    CASE
                        WHEN (am.amount = art2.amount)
                        THEN vat.amount
                            -- same as for invoice lines
                        ELSE ROUND(am.amount*vat.amount/ABS(art2.amount),2)
                    END
                ELSE 0
            END AS VAT,
            CASE
                    --when art2.amount = 0 then 0
                WHEN (il.center IS NOT NULL )
                THEN
                    CASE
                        WHEN (am.amount = art2.amount)
                        THEN il.total_amount
                            -- in the case the amount is a match for only part of the
                            -- invoice line,
                            -- we need to make it proportianal
                        ELSE ROUND(am.amount*il.total_amount/ABS(art2.amount),2)
                    END
                WHEN (cl.center IS NOT NULL )
                THEN
                    CASE
                        WHEN (am.amount = art2.amount)
                        THEN -cl.total_amount
                            -- same as for invoice lines
                        ELSE -ROUND(am.amount*cl.total_amount/ABS(art2.amount),2)
                    END
                ELSE SIGN(art.amount) * COALESCE(am.amount,0)
            END AS TOTAL
        FROM
            ACCOUNTS acc
        JOIN
            params
        ON
            params.id = acc.center
        JOIN
            ACCOUNT_TRANS act
        ON
            (
                act.DEBIT_ACCOUNTCENTER = acc.center
                AND act.DEBIT_ACCOUNTID = acc.id )
            OR (
                act.CREDIT_ACCOUNTCENTER = acc.center
                AND act.CREDIT_ACCOUNTID = acc.id )
        JOIN
            AR_TRANS art
        ON
            art.REF_TYPE = 'ACCOUNT_TRANS'
            AND art.REF_CENTER = act.center
            AND art.REF_ID = act.id
            AND art.REF_SUBID = act.subid
        LEFT JOIN
            ART_MATCH am
        ON
            am.ENTRY_TIME < params.ToDate
            AND (
                am.CANCELLED_TIME IS NULL
                OR am.CANCELLED_TIME > params.ToDate )
            AND ((
                    art.amount > 0
                    AND am.ART_PAYING_CENTER = art.center
                    AND am.ART_PAYING_id = art.id
                    AND am.ART_PAYING_subid = art.subid)
                OR (
                    art.amount <0
                    AND am.ART_PAID_CENTER = art.center
                    AND am.ART_PAID_id = art.id
                    AND am.ART_PAID_subid = art.subid))
        LEFT JOIN
            --cash account transactions that have been moved to payment account
            AR_TRANS art2
        ON
            (
                art.amount > 0
                AND am.ART_PAID_CENTER = art2.center
                AND am.ART_PAID_ID = art2.id
                AND am.ART_PAID_SUBID = art2.subid)
            OR (
                art.amount < 0
                AND am.ART_PAYING_CENTER = art2.center
                AND am.ART_PAYING_ID = art2.id
                AND am.ART_PAYING_SUBID = art2.subid)
        LEFT JOIN
            invoice_lines_mt il
        ON
            art2.REF_TYPE = 'INVOICE'
            AND art2.REF_CENTER = il.center
            AND art2.REF_ID = il.id
        LEFT JOIN
            credit_note_lines_mt cl
        ON
            (
                art2.REF_TYPE = 'CREDIT_NOTE'
                AND art2.REF_CENTER = cl.center
                AND art2.REF_ID = cl.id )
        LEFT JOIN
            ACCOUNT_TRANS vat
        ON
            (
                cl.center IS NOT NULL
                AND vat.center = cl.account_trans_center
                AND vat.id = cl.account_trans_id
                AND vat.subid = cl.account_trans_subid )
            OR (
                il.center IS NOT NULL
                AND vat.center = il.account_trans_center
                AND vat.id = il.account_trans_id
                AND vat.subid = il.account_trans_subid )
        LEFT JOIN
            ACCOUNT_TRANS act2
        ON
            (
                il.ACCOUNT_TRANS_CENTER IS NOT NULL
                AND act2.center = il.ACCOUNT_TRANS_CENTER
                AND act2.id = il.ACCOUNT_TRANS_ID
                AND act2.subid = il.ACCOUNT_TRANS_SUBID )
            OR (
                cl.ACCOUNT_TRANS_CENTER IS NOT NULL
                AND act2.center = cl.ACCOUNT_TRANS_CENTER
                AND act2.id = cl.ACCOUNT_TRANS_ID
                AND act2.subid = cl.ACCOUNT_TRANS_SUBID )
            OR (
                il.ACCOUNT_TRANS_CENTER IS NULL
                AND cl.ACCOUNT_TRANS_CENTER IS NULL
                AND art2.REF_TYPE = 'ACCOUNT_TRANS'
                AND art2.REF_CENTER = act2.center
                AND art2.REF_ID = act2.id
                AND art2.REF_SUBID = act2.subid )
        LEFT JOIN
            ACCOUNTS acc2
        ON
            ( (
                    art2.amount > 0
                    AND act2.DEBIT_ACCOUNTCENTER = acc2.CENTER
                    AND act2.DEBIT_ACCOUNTID = acc2.ID )
                OR (
                    art2.amount < 0
                    AND act2.CREDIT_ACCOUNTCENTER = acc2.CENTER
                    AND act2.CREDIT_ACCOUNTID = acc2.ID))
        WHERE
            acc.GLOBALID IN ( 'BANK_ACCOUNT_WEB_DEBT' ,
                             'BANK_ACCOUNT_WEB',
                             'PAYTEL',
                             'BANK_ACCOUNT_PT_CASH' )
            AND act.ENTRY_TIME >= params.FromDate
            AND act.ENTRY_TIME < params.ToDate
            AND am.ID IS NOT NULL
            AND act.amount <> 0 )t
GROUP BY
    center,
    account,
    type,
    trans_type,
    text
-- The transactions where settlements are not entirely done
UNION ALL
SELECT
    (
        SELECT
            c.EXTERNAL_ID
        FROM
            centers c
        WHERE
            c.id = center) AS CostCenter,
    (
        SELECT
            c.name
        FROM
            centers c
        WHERE
            c.id = center) AS Site,
    TYPE,
    account     AS ACCOUNT,
    'N/A'       AS trans_type,
    'N/A'       AS text,
    0           AS VAT,
    SUM(AMOUNT) AS AMOUNT
FROM
    (
        SELECT
            art.center,
            art.id,
            art.subid,
            acc.name AS account,
            CASE
                WHEN (art.amount > 0 )
                THEN 'PREPAYMENT'
                ELSE 'WITHDRAWAL'
            END AS TYPE,
            CASE
                WHEN art.amount > 0
                THEN art.amount - SUM(COALESCE(am.amount,0))
                ELSE art.amount + SUM(COALESCE(am.amount,0))
            END AS amount
        FROM
            ACCOUNTS acc
        JOIN
            params
        ON
            params.id = acc.center
        JOIN
            ACCOUNT_TRANS act
        ON
            (
                act.DEBIT_ACCOUNTCENTER = acc.center
                AND act.DEBIT_ACCOUNTID = acc.id )
            OR (
                act.CREDIT_ACCOUNTCENTER = acc.center
                AND act.CREDIT_ACCOUNTID = acc.id )
        JOIN
            AR_TRANS art
        ON
            art.REF_TYPE = 'ACCOUNT_TRANS'
            AND art.REF_CENTER = act.center
            AND art.REF_ID = act.id
            AND art.REF_SUBID = act.subid
        LEFT JOIN
            ART_MATCH am
        ON
            am.ENTRY_TIME < params.ToDate
            AND (
                am.CANCELLED_TIME IS NULL
                OR am.CANCELLED_TIME > params.ToDate )
            AND ((
                    art.amount > 0
                    AND am.ART_PAYING_CENTER = art.center
                    AND am.ART_PAYING_id = art.id
                    AND am.ART_PAYING_subid = art.subid)
                OR (
                    art.amount <0
                    AND am.ART_PAID_CENTER = art.center
                    AND am.ART_PAID_id = art.id
                    AND am.ART_PAID_subid = art.subid))
        LEFT JOIN
            --cash account transactions that have been moved to payment account
            AR_TRANS art2
        ON
            (
                art.amount > 0
                AND am.ART_PAID_CENTER = art2.center
                AND am.ART_PAID_ID = art2.id
                AND am.ART_PAID_SUBID = art2.subid)
            OR (
                art.amount < 0
                AND am.ART_PAYING_CENTER = art2.center
                AND am.ART_PAYING_ID = art2.id
                AND am.ART_PAYING_SUBID = art2.subid)
        WHERE
            acc.GLOBALID IN ('BANK_ACCOUNT_WEB_DEBT',
                             'BANK_ACCOUNT_WEB',
                             'PAYTEL',
                             'BANK_ACCOUNT_PT_CASH')
            AND act.ENTRY_TIME >= params.FromDate
            AND act.ENTRY_TIME < params.ToDate
            AND act.amount <> 0
        GROUP BY
            acc.name,
            art.center,
            art.id,
            art.subid,
            art.amount
        HAVING
            ABS(art.amount) <> SUM(COALESCE(am.amount,0)) ) k
GROUP BY
    center,
    TYPE,
    account