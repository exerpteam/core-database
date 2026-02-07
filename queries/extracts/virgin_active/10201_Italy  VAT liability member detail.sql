WITH
    params AS
    (
        SELECT
            /*+ materialize */
            r.* 
        FROM
            (
                SELECT
                    rp.END_DATE,
                    rp.END_DATE+1 AS CutDate,
                    datetolongTZ(TO_CHAR(rp.end_date + 1, 'YYYY-MM-DD HH24:MI'),
                    'Europe/Rome')   AS CutDateLong,
                    rp.CLOSE_TIME    AS CloseLong,
                    rp.HARD_CLOSE_TIME  AS HardCloseLong
                FROM
                    REPORT_PERIODS rp
                WHERE
                    rp.end_date IS NOT NULL
                AND rp.end_date >= $$DATE_IN_PERIOD$$
                AND rp.SCOPE_ID = 24
                ORDER BY
                    rp.END_DATE ASC) r
        WHERE
            rownum = 1
    )
SELECT
    CENTER,
    GL_CODE,
    SALES_CENTER,
    AR_TYPE,
    PRINTED,
    ROUND(SUM(OPEN_AMOUNT),2) OPEN_AMOUNT ,
    PERSON_ID ,
    SUM(OPEN_VAT_AMOUNT) AS OPEN_VAT_AMOUNT,
    CASE
        WHEN SUM(OPEN_VAT_AMOUNT) = 0
        THEN NULL
        ELSE VAT_CODE
    END AS VAT_CODE
    /*,AGE_MONTHS*/
FROM
    (
        SELECT
            ar.CENTER,
            'DEBT' SIGN,
            DECODE( ar.AR_TYPE ,
                   4,'payment',
                   5,'cashcollection' ,
                   1 ,'cash' ,
                   6,'installmentPlan' ,
                   'other' )                          AR_TYPE,
            acc.EXTERNAL_ID                           GL_CODE,
            vatacc.EXTERNAL_ID                        VAT_CODE,
            ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID PERSON_ID,
            CASE
                WHEN il.center IS NULL
                THEN ar.CENTER
                ELSE il.CENTER
            END                                               AS SALES_CENTER,
            art.CENTER || 'ar' || art.ID || 'tr' || art.SUBID    transID,
            floor(months_between( params.END_DATE,longtodateTZ(
                CASE
                    WHEN org2art.TRANS_TIME IS NOT NULL
                    THEN org2art.TRANS_TIME
                    WHEN orgart.TRANS_TIME IS NOT NULL
                    THEN orgart.TRANS_TIME
                    ELSE art.TRANS_TIME
                END, 'Europe/Rome'))) AS AGE_MONTHS,
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
            NVL(
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
                      OR  st.CANCELLED_TIME > params.CloseLong)
                  AND arts.CENTER = st.ART_PAYING_CENTER
                  AND arts.ID = st.ART_PAYING_ID
                  AND arts.SUBID = st.ART_PAYING_SUBID
                  AND arts.ENTRY_TIME < params.CloseLong
                  AND arts.TRANS_TIME < params.CutDateLong ),1) , 4) OPEN_AMOUNT,
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
            NVL(
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
                      OR  st.CANCELLED_TIME > params.CloseLong)
                  AND arts.CENTER = st.ART_PAYING_CENTER
                  AND arts.ID = st.ART_PAYING_ID
                  AND arts.SUBID = st.ART_PAYING_SUBID
                  AND arts.ENTRY_TIME < params.CloseLong
                  AND arts.TRANS_TIME < params.CutDateLong ),1) ,4) AS OPEN_VAT_AMOUNT,
            ( NVL(
                    (
                    SELECT DISTINCT
                        'ISSUED'
                    FROM
                        VA.PAYMENT_REQUEST_SPECIFICATIONS prs
                    JOIN
                        VA.PAYMENT_REQUESTS pr
                    ON
                        pr.INV_COLL_CENTER = prs.center
                    AND pr.INV_COLL_ID = prs.id
                    AND pr.INV_COLL_SUBID = prs.SUBID
                    WHERE
                        (
                            prs.CENTER, prs.id,prs.SUBID) IN ( (art.PAYREQ_SPEC_CENTER ,
                                                                art.PAYREQ_SPEC_ID ,
                                                                art.PAYREQ_SPEC_SUBID),
                                                              (orgart.PAYREQ_SPEC_CENTER ,
                                                              orgart.PAYREQ_SPEC_ID ,
                                                              orgart.PAYREQ_SPEC_SUBID),
                                                              (org2art.PAYREQ_SPEC_CENTER ,
                                                              org2art.PAYREQ_SPEC_ID ,
                                                              org2art.PAYREQ_SPEC_SUBID))
                    AND pr.REQUEST_TYPE IN (1,4,6,7)
                    AND pr.INVOICE_CREATED_AT < params.CloseLong ),'NOT_ISSUED') ) AS PRINTED
        FROM
            params
        CROSS JOIN
            ACCOUNT_RECEIVABLES ar
        JOIN
            AR_TRANS art
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
            ( params
        CROSS JOIN
            ART_MATCH tst
        JOIN
            AR_TRANS orgart
        ON
            orgart.CENTER = tst.ART_PAID_CENTER
        AND orgart.ID = tst.ART_PAID_ID
        AND orgart.SUBID = tst.ART_PAID_SUBID
        AND orgart.ENTRY_TIME < params.CloseLong
        AND orgart.TRANS_TIME < params.CutDateLong )
        ON
            tst.ART_PAYING_CENTER = tart.CENTER
        AND tst.ART_PAYING_ID = tart.ID
        AND tst.ART_PAYING_SUBID = tart.SUBID
        AND tst.ENTRY_TIME < params.CloseLong
        AND (
                tst.CANCELLED_TIME IS NULL
            OR  tst.CANCELLED_TIME > params.CloseLong)
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
            ( params
        CROSS JOIN
            ART_MATCH t2st
        JOIN
            AR_TRANS org2art
        ON
            org2art.CENTER = t2st.ART_PAID_CENTER
        AND org2art.ID = t2st.ART_PAID_ID
        AND org2art.SUBID = t2st.ART_PAID_SUBID
        AND org2art.ENTRY_TIME < params.CloseLong
        AND org2art.TRANS_TIME < params.CutDateLong )
        ON
            t2st.ART_PAYING_CENTER = t2art.CENTER
        AND t2st.ART_PAYING_ID = t2art.ID
        AND t2st.ART_PAYING_SUBID = t2art.SUBID
        AND t2st.ENTRY_TIME < params.CloseLong
        AND (
                t2st.CANCELLED_TIME IS NULL
            OR  t2st.CANCELLED_TIME > params.CloseLong)
        LEFT JOIN
            INVOICELINES il
        ON
            (
                orgart.center IS NULL
            AND art.REF_TYPE = 'INVOICE'
            AND art.REF_CENTER = il.center
            AND art.REF_ID = il.id )
        OR  (
                orgart.center IS NOT NULL
            AND orgart.REF_TYPE = 'INVOICE'
            AND orgart.REF_CENTER = il.center
            AND orgart.REF_ID = il.id )
        OR  (
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
        OR  (
                il.ACCOUNT_TRANS_CENTER IS NULL
            AND org2art.REF_TYPE = 'ACCOUNT_TRANS'
            AND org2art.REF_CENTER = gltrans.center
            AND org2art.REF_ID = gltrans.id
            AND org2art.REF_SUBID = gltrans.subid)
        OR  (
                il.ACCOUNT_TRANS_CENTER IS NULL
            AND org2art.REF_TYPE IS NULL
            AND orgart.REF_TYPE = 'ACCOUNT_TRANS'
            AND orgart.REF_CENTER = gltrans.center
            AND orgart.REF_ID = gltrans.id
            AND orgart.REF_SUBID = gltrans.subid)
        OR  (
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
            ACCOUNT_TRANS vattrans
        ON
            vattrans.center = il.VAT_ACC_TRANS_CENTER
        AND vattrans.id = il.VAT_ACC_TRANS_ID
        AND vattrans.subid = il.VAT_ACC_TRANS_SUBID
        LEFT JOIN
            ACCOUNTS vatacc
        ON
            vattrans.CREDIT_ACCOUNTCENTER = vatacc.CENTER
        AND vattrans.CREDIT_ACCOUNTID = vatacc.ID
        WHERE
            art.CENTER IN
            (
                SELECT
                    c.id
                FROM
                    centers c
                WHERE
                    c.id in ($$scope$$ ))
        AND
           
            art.AMOUNT < 0
        AND art.ENTRY_TIME < params.CloseLong
        AND art.TRANS_TIME < params.CutDateLong
        AND (
                ar.BALANCE <> 0
            OR  ar.LAST_ENTRY_TIME >= params.CutDateLong - (366 * 24 * 60 * 60 * 1000) )
            -- Only the rows in debt (% open > 0)
        AND NVL(
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
                      OR  st.CANCELLED_TIME > params.CloseLong)
                  AND arts.CENTER = st.ART_PAYING_CENTER
                  AND arts.ID = st.ART_PAYING_ID
                  AND arts.SUBID = st.ART_PAYING_SUBID
                  AND arts.ENTRY_TIME < params.CloseLong
                  AND arts.TRANS_TIME < params.CutDateLong ),1) > 0
        ORDER BY
            art.CENTER,
            art.ID,
            art.SUBID)
GROUP BY
    PRINTED,
    CENTER,
    GL_CODE,
    SALES_CENTER,
    VAT_CODE ,
    AR_TYPE
    ,PERSON_ID
   /**, AGE_MONTHS */
ORDER BY
    PRINTED,
    CENTER,
    AR_TYPE ,
     PERSON_ID , 
   /* , OPEN_AMOUNT
     ,AGE_MONTHS */
    
    GL_CODE