-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    periods.CENTER center,
	club.SHORTNAME,
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID personId,
    sub.CENTER || 'ss' || sub.ID subscription,
    DECODE(person.PERSONTYPE, 0, 'private', 1, 'student', 2, 'staff', 3, 'friend', 4, 'corporate', 5, 'one-man corp' , 6 , 'family', 7, 'senior', 8, 'guest') AS PersonType,
    prod.NAME,
    DECODE(st.ST_TYPE, 0, 'CASH', 1, 'EFT', 'ERROR') type,
    sub.SUBSCRIPTION_PRICE,
    sub.START_DATE subStartDate,
    sub.END_DATE subEndDate,
    pg.NAME productGroup,
    CASE
        WHEN sub.START_DATE >= :FromDate
            AND sub.START_DATE <= :ToDate
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS startInPeriod,
    CASE
        WHEN sub.END_DATE >= :FromDate
            AND sub.END_DATE <= :ToDate
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS endInPeriod,
    SUM(periods.periodDays) periodDays,
    SUM(periods.invoicedAmount) invoicedAmount,
    SUM(periods.invoicedDays) invoicedDays,
    SUM(periods.IntervalDays) intervalDays,
    SUM(periods.IntervalNormalDays) intervalNormalDays,
    SUM(periods.IntervalFreezeDays) intervalFreezeDays,
    SUM(periods.IntervalFreeDays) intervalFreeDays
FROM
    (
        SELECT
            I.CENTER,
            I.ID,
            I.PERSON_CENTER,
            I.PERSON_ID,
            SP.CENTER subCenter,
            SP.ID subId,
            :FromDate intervalFromDate,
            :ToDate intervalToDate,
            TO_CHAR(longtodate(I.TRANS_TIME), 'YYYY-MM-DD') bookDate,
            'INVOICE' lineType,
            DECODE(SP.SPP_TYPE, 1, 'NORMAL', 2, 'FREEZE', 3, 'FREE', 7, 'FREEZE', 'NONE') periodType,
            TO_CHAR(SP.FROM_DATE, 'YYYY-MM-DD') periodFromDate,
            TO_CHAR(SP.TO_DATE, 'YYYY-MM-DD') periodToDate,
            SP.TO_DATE-SP.FROM_DATE + 1 periodDays,
            SP.SUBSCRIPTION_PRICE periodPrice,
            IL.RATE VAT_RATE,
            CASE
                WHEN sponIl.TOTAL_AMOUNT IS NOT NULL
                THEN ROUND((IL.TOTAL_AMOUNT + sponIl.TOTAL_AMOUNT) - ((IL.TOTAL_AMOUNT + sponIl.TOTAL_AMOUNT) * (1-(1/(
                    1+il.RATE)))),2)
                ELSE ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),2)
            END AS invoicedAmount,
            CASE
                WHEN SP.SPP_TYPE = 1
                THEN SP.TO_DATE-SP.FROM_DATE + 1
                ELSE 0
            END AS invoicedDays,
            CASE
                WHEN SP.TO_DATE >= :FromDate
                    AND SP.FROM_DATE <= :ToDate
                THEN (LEAST(SP.TO_DATE, :ToDate ) - GREATEST(SP.FROM_DATE, :FromDate) + 1)
                ELSE 0
            END AS IntervalDays,
            CASE
                WHEN SPP_TYPE = 1
                    AND SP.FROM_DATE <= :ToDate
                    AND SP.TO_DATE >= :FromDate
                THEN LEAST(SP.TO_DATE, :ToDate ) - GREATEST(SP.FROM_DATE, :FromDate) + 1
                ELSE 0
            END AS IntervalNormalDays,
            CASE
                WHEN SPP_TYPE IN (2,7)
                    AND SP.FROM_DATE <= :ToDate
                    AND SP.TO_DATE >= :FromDate
                THEN LEAST(SP.TO_DATE, :ToDate ) - GREATEST(SP.FROM_DATE, :FromDate) + 1
                ELSE 0
            END AS IntervalFreezeDays,
            CASE
                WHEN SPP_TYPE = 3
                    AND SP.FROM_DATE <= :ToDate
                    AND SP.TO_DATE >= :FromDate
                THEN LEAST(SP.TO_DATE, :ToDate ) - GREATEST(SP.FROM_DATE, :FromDate) + 1
                ELSE 0
            END AS IntervalFreeDays
        FROM
            INVOICELINES IL
        JOIN INVOICES I
        ON
            I.CENTER= IL.CENTER
            AND I.ID= IL.ID
        JOIN PRODUCTS P
        ON
            P.CENTER= IL.PRODUCTCENTER
            AND P.ID= IL.PRODUCTID
        JOIN SUBSCRIPTIONPERIODPARTS SP
        ON
            IL.CENTER = SP.INVOICELINE_CENTER
            AND IL.ID = SP.INVOICELINE_ID
            AND IL.SUBID = SP.INVOICELINE_SUBID
        LEFT JOIN INVOICELINES sponIl
        ON
            sponIl.CENTER = I.SPONSOR_INVOICE_CENTER
            AND sponIl.ID = I.SPONSOR_INVOICE_ID
            AND sponIl.SUBID = IL.SPONSOR_INVOICE_SUBID
        WHERE
            I.CENTER IN (:Scope)
            AND P.PTYPE IN (7,10,12)
            AND I.TRANS_TIME >= datetolong(TO_CHAR(:FromDate, 'YYYY-MM-DD HH24:MI'))
            AND I.TRANS_TIME < datetolong(TO_CHAR(:ToDate, 'YYYY-MM-DD HH24:MI')) + 1000*60*60*24
        UNION ALL
        SELECT
            C.CENTER,
            C.ID,
            C.PERSON_CENTER,
            C.PERSON_ID,
            SP.CENTER subCenter,
            SP.ID subId,
            :FromDate intervalFromDate,
            :ToDate intervalToDate,
            TO_CHAR(longtodate(C.TRANS_TIME), 'YYYY-MM-DD') bookDate,
            'CREDIT' lineType,
            DECODE(SP.SPP_TYPE, 1, 'NORMAL', 2, 'FREEZE', 3, 'FREE', 7, 'FREEZE', 'NONE') periodType,
            TO_CHAR(SP.FROM_DATE, 'YYYY-MM-DD') periodFromDate,
            TO_CHAR(SP.TO_DATE, 'YYYY-MM-DD') periodToDate,
            -(SP.TO_DATE-SP.FROM_DATE + 1) periodDays,
            -SP.SUBSCRIPTION_PRICE periodPrice,
            -IL.RATE VAT_RATE,
            CASE
                WHEN sponIl.TOTAL_AMOUNT IS NOT NULL
                THEN -ROUND((IL.TOTAL_AMOUNT + sponIl.TOTAL_AMOUNT) - ((IL.TOTAL_AMOUNT + sponIl.TOTAL_AMOUNT) * (1-(1/
                    (1+il.RATE)))),2)
                ELSE -ROUND(il.TOTAL_AMOUNT - (il.TOTAL_AMOUNT * (1-(1/(1+il.RATE)))),2)
            END AS invoicedAmount,
            CASE
                WHEN SP.SPP_TYPE = 1
                THEN -(SP.TO_DATE-SP.FROM_DATE + 1)
                ELSE 0
            END AS invoicedDays,
            CASE
                WHEN SP.TO_DATE >= :FromDate
                    AND SP.FROM_DATE <= :ToDate
                THEN -(LEAST(SP.TO_DATE, :ToDate ) - GREATEST(SP.FROM_DATE, :FromDate) + 1)
                ELSE 0
            END AS IntervalDays,
            CASE
                WHEN SPP_TYPE = 1
                    AND SP.FROM_DATE <= :ToDate
                    AND SP.TO_DATE >= :FromDate
                THEN -(LEAST(SP.TO_DATE, :ToDate ) - GREATEST(SP.FROM_DATE, :FromDate) + 1)
                ELSE 0
            END AS IntervalNormalDays,
            CASE
                WHEN SPP_TYPE IN (2,7)
                    AND SP.FROM_DATE <= :ToDate
                    AND SP.TO_DATE >= :FromDate
                THEN -(LEAST(SP.TO_DATE, :ToDate ) - GREATEST(SP.FROM_DATE, :FromDate) + 1)
                ELSE 0
            END AS IntervalFreezeDays,
            CASE
                WHEN SPP_TYPE = 3
                    AND SP.FROM_DATE <= :ToDate
                    AND SP.TO_DATE >= :FromDate
                THEN -(LEAST(SP.TO_DATE, :ToDate ) - GREATEST(SP.FROM_DATE, :FromDate) + 1)
                ELSE 0
            END AS IntervalFreeDays
        FROM
            CREDIT_NOTE_LINES CL
        JOIN CREDIT_NOTES C
        ON
            C.CENTER= CL.CENTER
            AND C.ID= CL.ID
        JOIN PRODUCTS P
        ON
            P.CENTER= CL.PRODUCTCENTER
            AND P.ID= CL.PRODUCTID
        JOIN INVOICELINES IL
        ON
            CL.INVOICELINE_CENTER = IL.CENTER
            AND CL.INVOICELINE_ID = IL.ID
            AND CL.INVOICELINE_SUBID = IL.SUBID
        JOIN INVOICES I
        ON
            CL.INVOICELINE_CENTER = I.CENTER
            AND CL.INVOICELINE_ID = I.ID
        JOIN SUBSCRIPTIONPERIODPARTS SP
        ON
            IL.CENTER = SP.INVOICELINE_CENTER
            AND IL.ID = SP.INVOICELINE_ID
            AND IL.SUBID = SP.INVOICELINE_SUBID
        LEFT JOIN INVOICELINES sponIl
        ON
            sponIl.CENTER = I.SPONSOR_INVOICE_CENTER
            AND sponIl.ID = I.SPONSOR_INVOICE_ID
            AND sponIl.SUBID = IL.SPONSOR_INVOICE_SUBID
        WHERE
            C.CENTER IN (:Scope)
            AND P.PTYPE IN (7,10,12)
            AND C.TRANS_TIME >= datetolong(TO_CHAR(:FromDate, 'YYYY-MM-DD HH24:MI'))
            AND C.TRANS_TIME < datetolong(TO_CHAR(:ToDate, 'YYYY-MM-DD HH24:MI')) + 1000*60*60*24
    )
    periods
JOIN SUBSCRIPTIONS sub
ON
    periods.SubCenter = sub.CENTER
    AND periods.SubId = sub.ID
JOIN SUBSCRIPTIONTYPES st
ON
    sub.SUBSCRIPTIONTYPE_CENTER = st.CENTER
    AND sub.SUBSCRIPTIONTYPE_ID = st.ID
JOIN PRODUCTS prod
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID
JOIN PERSONS person
ON
    person.CENTER = sub.OWNER_CENTER
    AND person.id = sub.OWNER_ID
JOIN CENTERS club
ON
    person.CENTER = club.id
JOIN PRODUCT_GROUP pg
ON
    pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
GROUP BY
    periods.CENTER,
    club.SHORTNAME,
    sub.OWNER_CENTER || 'p' || sub.OWNER_ID,
    sub.CENTER || 'ss' || sub.ID,
    person.PERSONTYPE, 
    prod.NAME,
    st.ST_TYPE,
    sub.SUBSCRIPTION_PRICE,
    sub.START_DATE,
    sub.END_DATE,
    pg.NAME