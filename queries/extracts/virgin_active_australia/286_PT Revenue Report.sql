-- The extract is extracted from Exerp on 2026-02-08
--  
WITH Params AS (
    SELECT
        (EXTRACT(EPOCH FROM $$ToDate$$::timestamp) + 86400) * 1000 AS todate,
        ($$ToDate$$::timestamp + INTERVAL '1 day') AS todate_date
)

SELECT
    sales.SALES_TYPE,
    cMember.SHORTNAME AS HOME_CENTRE,
    CASE
        WHEN cRebook.SHORTNAME IS NOT NULL THEN cRebook.SHORTNAME
        ELSE cSales.SHORTNAME
    END AS PT_CENTRE,
    prod.NAME,
    CASE prod.PTYPE  
        WHEN 1 THEN 'Retail'
        WHEN 2 THEN 'Service'
        WHEN 4 THEN 'Clipcard'
        WHEN 5 THEN 'Subscription creation'
        WHEN 6 THEN 'Transfer'
        WHEN 7 THEN 'Freeze period'
        WHEN 8 THEN 'Gift card'
        WHEN 9 THEN 'Free gift card'
        WHEN 10 THEN 'Subscription'
        WHEN 12 THEN 'Subscription'
        WHEN 13 THEN 'Subscription add-on'
    END AS PT_TYPE,
    TO_CHAR(SUM(sales.TOTAL_AMOUNT), 'FM999999999999,9990.09') AS Year_to_date_Revenue,
    TO_CHAR(SUM(sales.NET_AMOUNT), 'FM999999999999,9990.09') AS Year_to_date_Revenue_excl_GST,
    SUM(sales.QUANTITY) AS year_to_date_count,
    TO_CHAR(SUM(
        CASE
            WHEN inv.TRANS_TIME BETWEEN
                (EXTRACT(EPOCH FROM date_trunc('month', Params.todate_date - INTERVAL '1 day')) * 1000)::bigint
                AND (EXTRACT(EPOCH FROM Params.todate_date) * 1000)::bigint
            THEN sales.TOTAL_AMOUNT
            ELSE 0
        END), 'FM999999999999,9990.09') AS Month_to_date_Revenue,
    TO_CHAR(SUM(
        CASE
            WHEN inv.TRANS_TIME BETWEEN
                (EXTRACT(EPOCH FROM date_trunc('month', Params.todate_date - INTERVAL '1 day')) * 1000)::bigint
                AND (EXTRACT(EPOCH FROM Params.todate_date) * 1000)::bigint
            THEN sales.NET_AMOUNT
            ELSE 0
        END), 'FM999999999999,9990.09') AS Month_to_date_Revenue_excl_GST,
    SUM(
        CASE
            WHEN inv.TRANS_TIME BETWEEN
                (EXTRACT(EPOCH FROM date_trunc('month', Params.todate_date - INTERVAL '1 day')) * 1000)::bigint
                AND (EXTRACT(EPOCH FROM Params.todate_date) * 1000)::bigint
            THEN 1 * sales.QUANTITY
            ELSE 0
        END) AS month_to_date_count
FROM
    INVOICE_LINES_MT sales
CROSS JOIN
    Params
JOIN
    PRODUCTS prod ON prod.CENTER = sales.PRODUCTCENTER AND prod.ID = sales.PRODUCTID
JOIN 
    INVOICES inv ON inv.CENTER = sales.CENTER AND inv.ID = sales.ID
JOIN
    CENTERS cMember ON cMember.ID = sales.PERSON_CENTER
JOIN
    CENTERS cSales ON cSales.ID = sales.ACCOUNT_TRANS_CENTER
JOIN
    ACCOUNT_TRANS act ON act.CENTER = sales.ACCOUNT_TRANS_CENTER AND act.ID = sales.ACCOUNT_TRANS_ID AND act.SUBID = sales.ACCOUNT_TRANS_SUBID
JOIN
    ACCOUNTS debit ON debit.CENTER = act.DEBIT_ACCOUNTCENTER AND debit.ID = act.DEBIT_ACCOUNTID
JOIN
    ACCOUNTS credit ON credit.CENTER = act.CREDIT_ACCOUNTCENTER AND credit.ID = act.CREDIT_ACCOUNTID
LEFT JOIN
    CENTERS cRebook ON cRebook.ID = sales.REBOOKING_TO_CENTER
LEFT JOIN
    PERSONS pp ON pp.CENTER = inv.PAYER_CENTER AND pp.id = inv.PAYER_ID
LEFT JOIN
    PERSONS pu ON pu.CENTER = sales.PERSON_CENTER AND pu.id = sales.PERSON_ID
WHERE
    inv.TRANS_TIME >= EXTRACT(EPOCH FROM date_trunc('month', Params.todate_date)) * 1000
    AND inv.TRANS_TIME < Params.todate
    AND (
        (sales.REBOOKING_TO_CENTER IS NULL AND sales.ACCOUNT_TRANS_CENTER IN ($$scope$$))
        OR (sales.REBOOKING_TO_CENTER IS NOT NULL AND sales.REBOOKING_TO_CENTER IN ($$scope$$))
    )
    AND (
        debit.EXTERNAL_ID IN ('1100','1110','1105','1120')
        OR credit.EXTERNAL_ID IN ('1100','1110','1105','1120')
    )
    AND NOT (
    prod.NAME ILIKE ANY (ARRAY[
        '%pro rata%',
        '%creation%'
    ])
)
GROUP BY
    sales.SALES_TYPE,
    cMember.SHORTNAME,
    prod.NAME,
    CASE prod.PTYPE  
        WHEN 1 THEN 'Retail'
        WHEN 2 THEN 'Service'
        WHEN 4 THEN 'Clipcard'
        WHEN 5 THEN 'Subscription creation'
        WHEN 6 THEN 'Transfer'
        WHEN 7 THEN 'Freeze period'
        WHEN 8 THEN 'Gift card'
        WHEN 9 THEN 'Free gift card'
        WHEN 10 THEN 'Subscription'
        WHEN 12 THEN 'Subscription'
        WHEN 13 THEN 'Subscription add-on'
    END,
    CASE
        WHEN cRebook.SHORTNAME IS NOT NULL THEN cRebook.SHORTNAME
        ELSE cSales.SHORTNAME
    END;