WITH
    params AS
    (
        SELECT
            /*+ materialize */
            rp.*,
            CAST((datetolongC(TO_CHAR((CAST(rp.END_DATE AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS cutDateLong,
            CAST((datetolongC(TO_CHAR((CAST($$REPORT_DATE$$ AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT)  AS ReportDateLong,
            c.id                                                                                                                  AS CENTER_ID
        FROM
            (
                SELECT
                    r.*
                FROM
                    (
                        SELECT
                            rp.END_DATE,
                            rp.END_DATE+1      AS CutDate,
                            rp.CLOSE_TIME      AS CloseLong,
                            rp.HARD_CLOSE_TIME AS HardCloseLong
                        FROM
                            REPORT_PERIODS rp
                        WHERE
                            rp.end_date IS NOT NULL
                            AND rp.end_date >= $$REPORT_DATE$$
                            AND rp.SCOPE_ID = 1
                        ORDER BY
                            rp.END_DATE ASC) r LIMIT 1 )rp,
            centers AS c
    )
    ,
    PERSON_V AS
    (
        SELECT DISTINCT
            per.center,
            per.id
        FROM
            persons per
        JOIN
            params
        ON
            params.CENTER_ID = per.center
        JOIN
            cashcollectioncases ccc
        ON
            ccc.personcenter = per.center
            AND ccc.personid = per.id
            AND ccc.missingpayment = 1
        JOIN
            cashcollectionjournalentries ccj
        ON
            ccj.center = ccc.center
            AND ccj.id = ccc.id
        WHERE
            per.center IN ($$Scope$$)
            AND (
                ccc.closed_datetime IS NULL
                OR ccc.closed_datetime >= params.ReportDateLong) -- only open ccc on report date
            AND ccj.creationtime <= params.ReportDateLong
            AND ccj.step >= $$Debt_Step_Number$$
    )
    ,
    TRANS_VIEW AS
    (
        SELECT
            CASE
                WHEN il.center IS NULL
                THEN ar.CENTER
                ELSE il.CENTER
            END                                     AS SALES_CENTER,
            ar.CUSTOMERCENTER                       AS PERSON_CENTER,
            ar.CUSTOMERID                           AS PERSON_ID,
            TO_CHAR(longtodatec(art.trans_time, art.center),'YYYY-MM-DD') AS BOOK_DATE,
            art.due_date                            AS DUE_DATE,
            TO_CHAR(longtodatec(art.entry_time, art.center),'YYYY-MM-DD') AS ENTRY_TIME,
            il.center || 'inv' || il.id             AS INV_ID,
            art.text                                AS AR_TEXT,
            prod.name                               AS PROD_NAME,
            acc.name                                AS ACC_NAME,
            acc.EXTERNAL_ID                         AS EXTERNAL_ID,
            -- Proportion of the open amount according to the invoice line
            ROUND(ABS(
                CASE
                    WHEN il.TOTAL_AMOUNT IS NULL
                        AND orgart.AMOUNT IS NULL
                        -- No invoice line, no transfer between accounts
                    THEN art.AMOUNT
                    WHEN il.TOTAL_AMOUNT IS NULL
                        AND org2art.AMOUNT IS NULL
                        -- No invoice line, no transfer between accounts
                    THEN orgart.AMOUNT * tst.AMOUNT/orgart.AMOUNT
                    WHEN il.TOTAL_AMOUNT IS NULL
                        AND org2art.AMOUNT IS NOT NULL
                        -- No invoice line but transfer between accounts twice
                    THEN org2art.AMOUNT * t2st.AMOUNT/org2art.AMOUNT* tst.AMOUNT/orgart.AMOUNT
                    WHEN tst.AMOUNT IS NULL
                        -- Invoice line on account
                    THEN IL.TOTAL_AMOUNT
                    WHEN t2st.AMOUNT IS NULL
                        -- Invoice line that has been transferred between accounts
                    THEN IL.TOTAL_AMOUNT* tst.AMOUNT/orgart.AMOUNT
                        -- Invoice line that has been transferred twice between accounts
                    ELSE IL.TOTAL_AMOUNT* t2st.AMOUNT/org2art.AMOUNT* tst.AMOUNT/ orgart.AMOUNT
                END) *
            -- How much is open (percentage)
            COALESCE(
                       (
                       SELECT
                           1+ SUM(st.AMOUNT) /art.AMOUNT
                       FROM
                           ART_MATCH st ,
                           AR_TRANS arts
                       WHERE
                           st.ART_PAID_CENTER = art.CENTER
                           AND st.ART_PAID_ID = art.ID
                           AND st.ART_PAID_SUBID = art.SUBID
                           AND st.ENTRY_TIME < params.CloseLong
                           AND (
                               st.CANCELLED_TIME IS NULL
                               OR st.CANCELLED_TIME > params.CloseLong)
                           AND arts.CENTER = st.ART_PAYING_CENTER
                           AND arts.ID = st.ART_PAYING_ID
                           AND arts.SUBID = st.ART_PAYING_SUBID
                           AND arts.ENTRY_TIME < params.CloseLong
                           AND arts.TRANS_TIME < params.CutDateLong ),1) , 4) AS OPEN_AMOUNT,
            -- Proportion of the open amount according to the invoice line
            ROUND(ABS(
                CASE
                    WHEN il.TOTAL_AMOUNT IS NULL
                        -- No invoice line
                    THEN 0
                    WHEN tst.AMOUNT IS NULL
                        -- Invoice line on account
                    THEN vattrans.AMOUNT
                        -- Invoice line that has been transferred between accounts
                    ELSE vattrans.AMOUNT* tst.AMOUNT/orgart.AMOUNT
                END) *
            -- How much is open (percentage)
            COALESCE(
                       (
                       SELECT
                           1+ SUM(st.AMOUNT) /art.AMOUNT
                       FROM
                           ART_MATCH st ,
                           AR_TRANS arts
                       WHERE
                           st.ART_PAID_CENTER = art.CENTER
                           AND st.ART_PAID_ID = art.ID
                           AND st.ART_PAID_SUBID = art.SUBID
                           AND st.ENTRY_TIME < params.CloseLong
                           AND (
                               st.CANCELLED_TIME IS NULL
                               OR st.CANCELLED_TIME > params.CloseLong)
                           AND arts.CENTER = st.ART_PAYING_CENTER
                           AND arts.ID = st.ART_PAYING_ID
                           AND arts.SUBID = st.ART_PAYING_SUBID
                           AND arts.ENTRY_TIME < params.CloseLong
                           AND arts.TRANS_TIME < params.CutDateLong ),1) ,4) AS OPEN_VAT_AMOUNT
        FROM
            params
        JOIN
            ACCOUNT_RECEIVABLES ar
        ON
            ar.CUSTOMERCENTER = params.CENTER_ID
        JOIN
            PERSON_V per_v
        ON
            per_v.center = ar.CUSTOMERCENTER
            AND per_v.id= ar.CUSTOMERID
        JOIN
            ar_trans art
        ON
            ar.CENTER = art.CENTER
            AND ar.ID = art.ID
            -- We want the GL codes
        LEFT JOIN
            -- transaction transfered from another account.
            AR_TRANS tart
        ON
            tart.REF_TYPE = art.ref_TYPE
            AND tart.ref_center = art.ref_center
            AND tart.ref_id = art.ref_id
            AND tart.ref_subid = art.ref_subid
            AND tart.id <> art.id
            AND tart.ENTRY_TIME < params.CloseLong
            AND tart.TRANS_TIME < params.CutDateLong
        LEFT JOIN
            ( params AS params1
        CROSS JOIN
            ART_MATCH tst
        JOIN
            AR_TRANS orgart
        ON
            orgart.CENTER = tst.ART_PAID_CENTER
            AND orgart.ID = tst.ART_PAID_ID
            AND orgart.SUBID = tst.ART_PAID_SUBID
            AND orgart.ENTRY_TIME < params1.CloseLong
            AND orgart.TRANS_TIME < params1.CutDateLong )
        ON
            tst.ART_PAYING_CENTER = tart.CENTER
            AND tst.ART_PAYING_ID = tart.ID
            AND tst.ART_PAYING_SUBID = tart.SUBID
            AND tst.ENTRY_TIME < params.CloseLong
            AND (
                tst.CANCELLED_TIME IS NULL
                OR tst.CANCELLED_TIME > params.CloseLong)
        LEFT JOIN
            -- transaction transfered from another account.
            AR_TRANS t2art
        ON
            t2art.REF_TYPE = orgart.ref_TYPE
            AND t2art.ref_center = orgart.ref_center
            AND t2art.ref_id = orgart.ref_id
            AND t2art.ref_subid = orgart.ref_subid
            AND t2art.id <> orgart.id
            AND t2art.ENTRY_TIME < params.CloseLong
            AND t2art.TRANS_TIME < params.CutDateLong
        LEFT JOIN
            ( params AS params2
        CROSS JOIN
            ART_MATCH t2st
        JOIN
            AR_TRANS org2art
        ON
            org2art.CENTER = t2st.ART_PAID_CENTER
            AND org2art.ID = t2st.ART_PAID_ID
            AND org2art.SUBID = t2st.ART_PAID_SUBID
            AND org2art.ENTRY_TIME < params2.CloseLong
            AND org2art.TRANS_TIME < params2.CutDateLong )
        ON
            t2st.ART_PAYING_CENTER = t2art.CENTER
            AND t2st.ART_PAYING_ID = t2art.ID
            AND t2st.ART_PAYING_SUBID = t2art.SUBID
            AND t2st.ENTRY_TIME < params.CloseLong
            AND (
                t2st.CANCELLED_TIME IS NULL
                OR t2st.CANCELLED_TIME > params.CloseLong)
        LEFT JOIN
            invoice_lines_mt il
        ON
            (
                orgart.center IS NULL
                AND art.REF_TYPE = 'INVOICE'
                AND art.REF_CENTER = il.center
                AND art.REF_ID = il.id )
            OR (
                orgart.center IS NOT NULL
                AND orgart.REF_TYPE = 'INVOICE'
                AND orgart.REF_CENTER = il.center
                AND orgart.REF_ID = il.id )
            OR (
                org2art.center IS NOT NULL
                AND org2art.REF_TYPE = 'INVOICE'
                AND org2art.REF_CENTER = il.center
                AND org2art.REF_ID = il.id )
        LEFT JOIN
            ACCOUNT_TRANS gltrans
        ON
            (
                il.ACCOUNT_TRANS_CENTER IS NOT NULL
                AND gltrans.center = il.ACCOUNT_TRANS_CENTER
                AND gltrans.id = il.ACCOUNT_TRANS_ID
                AND gltrans.subid = il.ACCOUNT_TRANS_SUBID )
            OR (
                il.ACCOUNT_TRANS_CENTER IS NULL
                AND org2art.REF_TYPE = 'ACCOUNT_TRANS'
                AND org2art.REF_CENTER = gltrans.center
                AND org2art.REF_ID = gltrans.id
                AND org2art.REF_SUBID = gltrans.subid)
            OR (
                il.ACCOUNT_TRANS_CENTER IS NULL
                AND org2art.REF_TYPE IS NULL
                AND orgart.REF_TYPE = 'ACCOUNT_TRANS'
                AND orgart.REF_CENTER = gltrans.center
                AND orgart.REF_ID = gltrans.id
                AND orgart.REF_SUBID = gltrans.subid)
            OR (
                il.ACCOUNT_TRANS_CENTER IS NULL
                AND orgart.REF_TYPE IS NULL
                AND art.REF_TYPE = 'ACCOUNT_TRANS'
                AND art.REF_CENTER = gltrans.center
                AND art.REF_ID = gltrans.id
                AND art.REF_SUBID = gltrans.subid )
        LEFT JOIN
            ACCOUNTS acc
        ON
            gltrans.CREDIT_ACCOUNTCENTER = acc.CENTER
            AND gltrans.CREDIT_ACCOUNTID = acc.ID
        LEFT JOIN
            INVOICELINES_VAT_AT_LINK ivat
        ON
            ivat.INVOICELINE_CENTER=il.CENTER
            AND ivat.INVOICELINE_ID=il.ID
            AND ivat.INVOICELINE_SUBID=il.SUBID
        LEFT JOIN
            ACCOUNT_TRANS vattrans
        ON
            vattrans.center = ivat.ACCOUNT_TRANS_CENTER
            AND vattrans.id = ivat.ACCOUNT_TRANS_ID
            AND vattrans.subid = ivat.ACCOUNT_TRANS_SUBID
        LEFT JOIN
            ACCOUNTS vatacc
        ON
            vattrans.CREDIT_ACCOUNTCENTER = vatacc.CENTER
            AND vattrans.CREDIT_ACCOUNTID = vatacc.ID
        LEFT JOIN
            products prod
        ON
            prod.center = il.productcenter
            AND prod.id = il.productid
        WHERE
            art.AMOUNT < 0
            AND art.ENTRY_TIME < params.CloseLong
            AND art.TRANS_TIME < params.CutDateLong
            AND (
                ar.BALANCE <> 0
                OR ar.LAST_ENTRY_TIME >= params.CutDateLong - (CAST(366 * 24 * 60 * 60 AS BIGINT) * 1000) )
            -- Only the rows in debt (% open > 0)
            AND COALESCE(
                           (
                           SELECT
                               1- SUM(st.AMOUNT) /ABS(art.AMOUNT)
                           FROM
                               ART_MATCH st ,
                               AR_TRANS arts
                           WHERE
                               st.ART_PAID_CENTER = art.CENTER
                               AND st.ART_PAID_ID = art.ID
                               AND st.ART_PAID_SUBID = art.SUBID
                               AND st.ENTRY_TIME < params.CloseLong
                               AND (
                                   st.CANCELLED_TIME IS NULL
                                   OR st.CANCELLED_TIME > params.CloseLong)
                               AND arts.CENTER = st.ART_PAYING_CENTER
                               AND arts.ID = st.ART_PAYING_ID
                               AND arts.SUBID = st.ART_PAYING_SUBID
                               AND arts.ENTRY_TIME < params.CloseLong
                               AND arts.TRANS_TIME < params.CutDateLong ),1) > 0
    )
    ,
    TRANS_AGG_VIEW AS
    (
        SELECT
            tv.sales_center,
            tv.person_center,
            tv.person_id,
            tv.BOOK_DATE,
            tv.DUE_DATE,
            tv.ENTRY_TIME,
            tv.INV_ID,
            tv.AR_TEXT,
            tv.PROD_NAME,
            tv.ACC_NAME,
            tv.EXTERNAL_ID,
            SUM(tv.OPEN_AMOUNT) AS OPEN_AMOUNT,
            SUM(tv.OPEN_VAT_AMOUNT) AS OPEN_VAT_AMOUNT
        FROM
            TRANS_VIEW tv
        GROUP BY
            tv.sales_center,
            tv.person_center,
            tv.person_center,
            tv.person_id,
            tv.BOOK_DATE,
            tv.DUE_DATE,
            tv.ENTRY_TIME,
            tv.INV_ID,
            tv.AR_TEXT,
            tv.PROD_NAME,
            tv.ACC_NAME,
            tv.EXTERNAL_ID
    )
SELECT
    t.sales_center                        AS "Invoice ID",
    salescenter.name                      AS "Sales Center Name",
    t.person_center                       AS "Person Center",
    percenter.name                        AS "Person Center Name",
    t.person_center || 'p' || t.person_id AS "Person Id",
    per.fullname                          AS "Person Name",
    t.BOOK_DATE                           AS "Book Date",
    t.DUE_DATE                            AS "Due date",
    t.ENTRY_TIME                          AS "Entry Time",
    t.INV_ID                              AS "Invoice Id",
    t.AR_TEXT                             AS "AR Transaction Text",
    t.PROD_NAME                           AS "Product Name",
    t.ACC_NAME                            AS "Account Name",
    t.EXTERNAL_ID                         AS "External Id",
    t.OPEN_AMOUNT                         AS "Open Amount",
    t.OPEN_VAT_AMOUNT                     AS "Open VAT Amount",
    t.OPEN_AMOUNT-t.OPEN_VAT_AMOUNT       AS "Open Revenue Amount"
FROM
    TRANS_AGG_VIEW t
JOIN
    persons per
ON
    per.center = t.person_center
    AND per.id = t.person_id
JOIN
    centers percenter
ON
    percenter.id = t.person_center
JOIN
    centers salescenter
ON
    salescenter.id = t.sales_center