-- This is the version from 2026-02-05
--  
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
                    exerpro.datetolongTZ(TO_CHAR(rp.end_date + 1, 'YYYY-MM-DD HH24:MI'),
                    'Europe/Rome')     AS CutDateLong,
                    rp.CLOSE_TIME      AS CloseLong,
                    rp.HARD_CLOSE_TIME AS HardCloseLong
                FROM
                    REPORT_PERIODS rp
                WHERE
                    rp.end_date IS NOT NULL
                AND rp.end_date >= $$DATEINPERIOD$$
                AND rp.SCOPE_ID = 2
                ORDER BY
                    rp.END_DATE ASC) r
        WHERE
            rownum = 1
    )
SELECT
    CENTER,
    AR_TYPE,
    DEBTOR_TYPE,
    ROUND(SUM(OPEN_AMOUNT),2) OPEN_AMOUNT ,
    PERSON_ID
    --, AGE_MONTHS
FROM
    (
        SELECT
            ar.CENTER,
            DECODE( ar.AR_TYPE ,
                   4,'payment',
                   5,'cashcollection' ,
                   1 ,'cash' ,
                   6,'installmentPlan' ,
                   'other' )                             AR_TYPE,
            ar.CUSTOMERCENTER || 'p' || ar.CUSTOMERID AS PERSON_ID,
            (
                SELECT
                    CASE
                        WHEN sex = 'C'
                        THEN 'COMPANY'
                        ELSE 'PERSON'
                    END
                FROM
                    persons p
                WHERE
                    (
                        p.center,p.id) IN((ar.CUSTOMERCENTER,
                                           ar.CUSTOMERID )))  AS DEBTOR_TYPE,
            art.CENTER || 'ar' || art.ID || 'tr' || art.SUBID    transID,
            floor(months_between( params.END_DATE,exerpro.longtodateTZ(art.TRANS_TIME,
            'Europe/Rome'))) AS AGE_MONTHS,
            -- Proportion of the open amount according to the invoice line
            ROUND( art.AMOUNT *
            -- How much is open (percentage)
            NVL(
                  (
                  SELECT
                      1- SUM(st.AMOUNT) /ABS(art.AMOUNT)
                  FROM
                      ART_MATCH st ,
                      AR_TRANS arts
                  WHERE
                      st.ENTRY_TIME < params.CloseLong
                  AND (
                          st.CANCELLED_TIME IS NULL
                      OR  st.CANCELLED_TIME > params.CloseLong)
                  AND arts.ENTRY_TIME < params.CloseLong
                  AND arts.TRANS_TIME < params.CutDateLong
                  AND ((
                              art.AMOUNT < 0
                          AND st.ART_PAID_CENTER = art.CENTER
                          AND st.ART_PAID_ID = art.ID
                          AND st.ART_PAID_SUBID = art.SUBID
                          AND arts.CENTER = st.ART_PAYING_CENTER
                          AND arts.ID = st.ART_PAYING_ID
                          AND arts.SUBID = st.ART_PAYING_SUBID )
                      OR  (
                              art.AMOUNT > 0
                          AND st.ART_PAID_CENTER = arts.CENTER
                          AND st.ART_PAID_ID = arts.ID
                          AND st.ART_PAID_SUBID = arts.SUBID
                          AND art.CENTER = st.ART_PAYING_CENTER
                          AND art.ID = st.ART_PAYING_ID
                          AND art.SUBID = st.ART_PAYING_SUBID ))),1) , 4) AS OPEN_AMOUNT
        FROM
            params
        CROSS JOIN
            ACCOUNT_RECEIVABLES ar
        JOIN
            AR_TRANS art
        ON
            ar.CENTER = art.CENTER
        AND ar.ID = art.ID
        WHERE
            art.CENTER IN
            (
                SELECT
                    c.id
                FROM
                    centers c
                WHERE
                    c.id = $$center$$  )
        AND
            -- HERE you can filter on <0 for DEBT only and >0 for POSITIVE amounts only
            art.AMOUNT <> 0
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
    CENTER,
    AR_TYPE ,
    DEBTOR_TYPE ,
    PERSON_ID
    -- AGE_MONTHS
HAVING
    ROUND(SUM(OPEN_AMOUNT),2) <> 0
ORDER BY
    CENTER,
    DEBTOR_TYPE,
    AR_TYPE ,
    PERSON_ID,
    OPEN_AMOUNT
    -- AGE_MONTHS