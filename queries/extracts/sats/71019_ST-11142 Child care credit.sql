WITH
    params AS
    (
        SELECT
            /*+ materialize */
            to_date('2020-05-01','yyyy-MM-dd') AS from_date,
            to_date('2020-05-31','yyyy-MM-dd') AS to_date
        FROM
            dual
    )
SELECT
    FLOOR((ROW_NUMBER() OVER(ORDER BY center,ID) / 500)) + 1 AS THREADGROUP,
    owner_center                                             AS PERSON_CENTER,
    owner_id                                                 AS PERSON_ID,
    'PAYMENT'                                                AS ACCOUNT_RECEIVABLE_TYPE,
    PRODUCT_CENTER,
    PRODUCT_ID,
    ceil(ROUND(TOTAL_AMOUNT / inv_days,2) * covid_credit_days) AS AMOUNT,
    QUANTITY,
    TO_CHAR(TRUNC(SYSDATE)) AS BOOK_DATE,
    'COVID19 Childcare ' || TO_CHAR(credit_period_start, 'yyyy-MM-dd') || ' - ' || TO_CHAR
    (credit_period_end, 'yyyy-MM-dd') AS TEXT
FROM
    (
        SELECT
            s.owner_center,
            s.owner_id ,
            s.center,
            s.id,
            spp.FROM_DATE AS period_start,
            spp.TO_DATE   AS period_end,
            il.TOTAL_AMOUNT,
            GREATEST(spp.FROM_DATE ,s.start_date, params.from_Date)          AS credit_period_start,
            LEAST(spp.TO_DATE, NVL(s.end_date, spp.TO_DATE), params.to_date)   AS credit_period_end,
            LEAST(spp.TO_DATE, params.to_date) - GREATEST (spp.FROM_DATE , params.from_Date) + 1 AS
                                               covid_credit_days,
            spp.TO_DATE - spp.FROM_DATE + 1 AS inv_days,
            pr.center                       AS PRODUCT_CENTER,
            pr.id                           AS PRODUCT_ID,
            il.quantity,
            sa.id AS said,
            sa.START_DATE,
            sa.END_DATE
        FROM
            params,
            SATS.SUBSCRIPTION_ADDON sa
        JOIN
            SATS.SUBSCRIPTIONS s
        ON
            s.CENTER = sa.SUBSCRIPTION_CENTER
        AND s.id = sa.SUBSCRIPTION_ID
        JOIN
            SATS.MASTERPRODUCTREGISTER mpr
        ON
            mpr.id = sa.ADDON_PRODUCT_ID
        JOIN
            SATS.SUBSCRIPTIONPERIODPARTS spp
        ON
            spp.CENTER = sa.SUBSCRIPTION_CENTER
        AND spp.id = sa.SUBSCRIPTION_ID
        JOIN
            SATS.SPP_INVOICELINES_LINK sppl
        ON
            sppl.PERIOD_CENTER = spp.center
        AND sppl.PERIOD_ID = spp.id
        AND sppl.PERIOD_SUBID = spp.subid
        JOIN
            SATS.INVOICE_LINES_MT il
        ON
            il.center = sppl.INVOICELINE_CENTER
        AND il.id = sppl.INVOICELINE_ID
        AND il.subid = sppl.INVOICELINE_SUBID
        JOIN
            SATS.PRODUCTS pr
        ON
            pr.center = il.PRODUCTCENTER
        AND pr.id = il.PRODUCTID
        AND pr.GLOBALID = mpr.GLOBALID
        WHERE
            spp.TO_DATE >= params.from_date
        AND spp.FROM_DATE <= params.to_date
        AND (
                SA.END_DATE >= params.from_date
            OR  SA.end_date IS NULL)
        AND SA.START_DATE <= params.to_date
        AND mpr.GLOBALID = 'CHILD_CARE_2019'
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    SATS.CREDIT_NOTE_LINES_MT cl
                WHERE
                    cl.INVOICELINE_CENTER = il.center
                AND cl.INVOICELINE_ID = il.id
                AND cl.INVOICELINE_SUBID = il.subid)
        AND il.TOTAL_AMOUNT > 0
        AND sa.CANCELLED = 0
        AND s.center IN ($$scope$$) ) x