-- The extract is extracted from Exerp on 2026-02-08
--  
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
        THEN ROUND((IL.TOTAL_AMOUNT + sponIl.TOTAL_AMOUNT) - ((IL.TOTAL_AMOUNT + sponIl.TOTAL_AMOUNT) * (1-(1/(1+
            il.RATE)))),2)
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
JOIN SPP_INVOICELINES_LINK ILPP
ON
    ILPP.INVOICELINE_CENTER = IL.CENTER
    AND ILPP.INVOICELINE_ID = IL.ID
    AND ILPP.INVOICELINE_SUBID = IL.SUBID
JOIN SUBSCRIPTIONPERIODPARTS SP
ON
    ILPP.PERIOD_CENTER = SP.CENTER
    AND ILPP.PERIOD_ID = SP.ID
    AND ILPP.PERIOD_SUBID = SP.SUBID
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
        THEN -ROUND((IL.TOTAL_AMOUNT + sponIl.TOTAL_AMOUNT) - ((IL.TOTAL_AMOUNT + sponIl.TOTAL_AMOUNT) * (1-(1/(1+
            il.RATE)))),2)
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
JOIN SPP_INVOICELINES_LINK ILPP
ON
    ILPP.INVOICELINE_CENTER = IL.CENTER
    AND ILPP.INVOICELINE_ID = IL.ID
    AND ILPP.INVOICELINE_SUBID = IL.SUBID
JOIN SUBSCRIPTIONPERIODPARTS SP
ON
    ILPP.PERIOD_CENTER = SP.CENTER
    AND ILPP.PERIOD_ID = SP.ID
    AND ILPP.PERIOD_SUBID = SP.SUBID
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
