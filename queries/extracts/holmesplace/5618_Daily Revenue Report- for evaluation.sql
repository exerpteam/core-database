WITH
    PARAMS AS
    (
        SELECT
            TRUNC(ParamDate, 'MONTH') AS FromDate,
            ParamDate                 AS ToDate
        FROM
            (
                SELECT
                    :for_date AS ParamDate
                FROM
                    dual )
    )
SELECT
    NVL(co.NAME, 'Holmes Place Europe') AS "Country",
    NVL(c.WEB_NAME, 'Total '|| co.Name) AS "Club",
    MAX(
        CASE
            WHEN fie.key = 'LIVEMEMBERS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS "LIVEMEMBERS",
    MAX(
        CASE
            WHEN fie.key = 'FROZEN'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS "FROZEN",
    MAX(
        CASE
            WHEN fie.key = 'EXTRA'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS "EXTRAS",
    MAX(
        CASE
            WHEN fie.key = 'LATESTART'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS "LATESTARTERS",
    MAX(
        CASE
            WHEN fie.key = 'LIVEMEMBERLOSS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                          AS "LEAVERS",
    SUM(DECODE(fie.key, 'PT_BOOKINGS', dat.value, 0)) AS "MTD pt BOOKINGS",
    MAX(
        CASE
            WHEN fie.key = 'DD_SALES_TOTAL'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                             AS "Daily DD Sales Revenue",
    SUM(DECODE(fie.key, 'DD_SALES_TOTAL', dat.value, 0)) AS "MTD DD sales revenue",
    MAX(
        CASE
            WHEN fie.key = 'DD_SALES_24_MONTH'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                                AS "Daily DD Sales 24M Revenue",
    SUM(DECODE(fie.key, 'DD_SALES_24_MONTH', dat.value, 0)) AS "MTD DD sales 24M revenue",
    MAX(
        CASE
            WHEN fie.key = 'STARTERPACK_REVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                                  AS "Daily Starterpack Revenue",
    SUM(DECODE(fie.key, 'STARTERPACK_REVENUE', dat.value, 0)) AS "MTD Starterpack revenue",
        MAX(
        CASE
            WHEN fie.key = 'AdminFee'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END)                                                  AS "Daily Admin Fee Revenue",
    SUM(DECODE(fie.key, 'AdminFee', dat.value, 0)) AS "MTD Admin Fee revenue",
    MAX(
        CASE
            WHEN fie.key = 'JoiningFee'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END)                                                  AS "Daily Joining Fee Revenue",
    SUM(DECODE(fie.key, 'JoiningFee', dat.value, 0)) AS "MTD Joining Fee revenue",
    MAX(
        CASE
            WHEN fie.key = 'PT_BY_DD_SOLD'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                            AS "Daily PT by dd sold",
    SUM(DECODE(fie.key, 'PT_BY_DD_SOLD', dat.value, 0)) AS "MTD PT by dd sold",
    SUM(DECODE(fie.key, 'PT_REVENUE', dat.value, 0))    AS "MTD PT Revenue",
    MAX(
        CASE
            WHEN fie.key = 'PT_REVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS "Daily PT Revenue",
    MAX(
        CASE
            WHEN fie.key = 'GRITREVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                          AS "Daily grit Revenue",
    SUM(DECODE(fie.key, 'GRITREVENUE', dat.value, 0)) AS "MTD Grit Revenue",
    MAX(
        CASE
            WHEN fie.key = 'STUDIO_REVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                             AS "Daily Studio Revenue",
    SUM(DECODE(fie.key, 'STUDIO_REVENUE', dat.value, 0)) AS "MTD Studio Revenue",
    MAX(
        CASE
            WHEN fie.key = 'NUTRITION_REVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                                AS "Daily Nutrition Revenue",
    SUM(DECODE(fie.key, 'NUTRITION_REVENUE', dat.value, 0)) AS "MTD Nutrition Revenue",
    MAX(
        CASE
            WHEN fie.key = 'RetailRevenue'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                            AS "Daily Retail Revenue",
    SUM(DECODE(fie.key, 'RetailRevenue', dat.value, 0)) AS "MTD Retail Revenue",
    MAX(
        CASE
            WHEN fie.key = 'TotalRevenue'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END)                                           AS "Daily total Revenue",
    SUM(DECODE(fie.key, 'TotalRevenue', dat.value, 0)) AS "MTD Total Revenue"
FROM
    PARAMS,
    centers c
JOIN
    countries co
ON
    co.id = c.country
JOIN
    kpi_data dat
ON
    dat.center = c.id
JOIN
    kpi_fields fie
ON
    fie.id = dat.field
WHERE
    -- Opening/Closing fields
    -- Put fields where you are only interested by the values at opening and closing (or only one of them)
    (
        fie.key IN ('xx')
        AND (
            dat.for_date = PARAMS.FromDate - 1
            OR dat.for_date = PARAMS.ToDate) )
    OR (
        -- Movement fields: fields that need to be sum/aggregated in the extract
        fie.key IN ( 'LIVEMEMBERS',
                    'FROZEN',
                    'EXTRA',
                    'LATESTART',
                    'LIVEMEMBERLOSS',
                    'PT_BOOKINGS',
                    'DD_SALES_TOTAL',
                    'DD_SALES_24_MONTH',
                    'STARTERPACK_REVENUE',
                    'PPT_BY_DD_SOLD',
                    'PT_REVENUE',
                    'GRITREVENUE',
                    'STUDIO_REVENUE',
                    'NUTRITION_REVENUE',
                    'RetailRevenue',
                    'TotalRevenue',
                    'JoiningFee',
                    'AdminFee' )
        AND dat.for_date BETWEEN PARAMS.FromDate AND PARAMS.ToDate )
    AND c.id IN (:scope)
GROUP BY
    ROLLUP(
    --REGION,
    co.NAME, c.web_name)