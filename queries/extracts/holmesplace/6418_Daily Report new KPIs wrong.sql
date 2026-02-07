WITH
    PARAMS AS
    (
        SELECT
            date_trunc('month', par.ParamDate) AS FromDate,
            par.ParamDate-1                   as ToDate2,
            par.ParamDate                     AS ToDate
            
        FROM
            (
                SELECT
                    CAST(:for_date AS DATE) AS ParamDate) par
    )
SELECT
    COALESCE(co.NAME, 'Holmes Place Europe') AS "Country",
    COALESCE(c.WEB_NAME, 'Total '|| co.Name) AS "Club",
    SUM(
        CASE
            WHEN fie.key = 'LIVEMEMBERS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "LIVEMEMBERS",
    SUM(
        CASE
            WHEN fie.key = 'LiveMemberBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "LiveMemberBudget",
    SUM(
        CASE
            WHEN fie.key = 'FROZEN'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "FROZEN",
    SUM(
        CASE
            WHEN fie.key = 'EXTRA'
                AND for_date = PARAMS.ToDate2
            THEN dat.value
            ELSE NULL
        END) AS "EXTRAS",
    SUM(
        CASE
            WHEN fie.key = 'LATESTART'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "LATESTARTERS",
    SUM(
        CASE
            WHEN fie.key = 'LIVEMEMBERLOSS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "DAILYLEAVERS",
    SUM( (
            CASE fie.key
                WHEN 'LIVEMEMBERLOSS'
                THEN dat.value
                ELSE 0
            END)) AS "TotalLeavers",
    SUM(
        CASE
            WHEN fie.key = 'LeaversBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "LeaversBudget",
    SUM( (
            CASE fie.key
                WHEN 'PT_BOOKINGS'
                THEN dat.value
                ELSE 0
            END)) AS "MTD pt BOOKINGS",
    SUM(
        CASE
            WHEN fie.key = 'DD_SALES_TOTAL'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily DD Sales Revenue",
    SUM( (
            CASE fie.key
                WHEN 'DD_SALES_TOTAL'
                THEN dat.value
                ELSE 0
            END)) AS "MTD DD sales revenue",
    SUM(
        CASE
            WHEN fie.key = 'JoinersBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "JoinersBudget",
    SUM(
        CASE
            WHEN fie.key = 'DD_SALES_24_MONTH'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily DD Sales 24M Revenue",
    SUM( (
            CASE fie.key
                WHEN 'DD_SALES_24_MONTH'
                THEN dat.value
                ELSE 0
            END)) AS "MTD DD sales 24M revenue",
    SUM(
        CASE
            WHEN fie.key = 'STARTERPACK_REVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily Starterpack Revenue",
    SUM( (
            CASE fie.key
                WHEN 'STARTERPACK_REVENUE'
                THEN dat.value
                ELSE 0
            END)) AS "MTD Starterpack revenue",
    SUM(
        CASE
            WHEN fie.key = 'PT_BY_DD_SOLD'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily PT by dd sold",
    SUM( (
            CASE fie.key
                WHEN 'PT_BY_DD_SOLD'
                THEN dat.value
                ELSE 0
            END)) AS "MTD PT by dd sold",
    SUM( (
            CASE fie.key
                WHEN 'GymIncome'
                THEN dat.value
                ELSE 0
            END)) AS "MTD GymIncome",
    SUM(
        CASE
            WHEN fie.key = 'GymIncome'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily GYmIncome",
    SUM(
        CASE
            WHEN fie.key = 'GRITREVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily grit Revenue",
    SUM( (
            CASE fie.key
                WHEN 'GRITREVENUE'
                THEN dat.value
                ELSE 0
            END)) AS "MTD Grit Revenue",
    SUM(
        CASE
            WHEN fie.key = 'STUDIO_REVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily Studio Revenue",
    SUM( (
            CASE fie.key
                WHEN 'STUDIO_REVENUE'
                THEN dat.value
                ELSE 0
            END)) AS "MTD Studio Revenue",
    SUM(
        CASE
            WHEN fie.key = 'NUTRITION_REVENUE'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily Nutrition Revenue",
    SUM( (
            CASE fie.key
                WHEN 'NUTRITION_REVENUE'
                THEN dat.value
                ELSE 0
            END)) AS "MTD Nutrition Revenue",
    SUM(
        CASE
            WHEN fie.key = 'ReceptionIncome'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily Reception Income",
    SUM( (
            CASE fie.key
                WHEN 'ReceptionIncome'
                THEN dat.value
                ELSE 0
            END)) AS "MTD Reception Income",
    SUM(
        CASE
            WHEN fie.key = 'TotalRevenue2'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily total Revenue",
    SUM( (
            CASE fie.key
                WHEN 'TotalRevenue2'
                THEN dat.value
                ELSE 0
            END)) AS "MTD Total Revenue",
    SUM(
        CASE
            WHEN fie.key = 'TotalRevenueBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "TotalRevenueBudget",
    SUM(
        CASE
            WHEN fie.key = 'PTBookingBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "PTBookingBudget",
    SUM(
        CASE
            WHEN fie.key = 'PTRevenueBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "PTRevenueBudget",
    SUM(
        CASE
            WHEN fie.key = 'GritRevenueBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "GritRevenueBudget",
    SUM(
        CASE
            WHEN fie.key = 'StudioRevenueBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "StudioRevenueBudget",
    SUM(
        CASE
            WHEN fie.key = 'NutritionRevenueBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "NutritionRevenueBudget",
    SUM(
        CASE
            WHEN fie.key = 'RetailRevenueBudget'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "RetailRevenueBudget",
    SUM(
        CASE
            WHEN fie.key = 'AdminFee'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily Admin Fee Revenue",
    SUM( (
            CASE fie.key
                WHEN 'AdminFee'
                THEN dat.value
                ELSE 0
            END)) AS "MTD Admin Fee revenue",
    SUM(
        CASE
            WHEN fie.key = 'JoiningFee'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE NULL
        END) AS "Daily Joining Fee Revenue",
    SUM( (
            CASE fie.key
                WHEN 'JoiningFee'
                THEN dat.value
                ELSE 0
            END)) AS "MTD Joining Fee revenue"
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
            dat.for_date = PARAMS.FromDate - interval '1 day'
            OR dat.for_date = PARAMS.ToDate) )
   OR ((
        -- Movement fields: fields that need to be sum/aggregated in the extract
        fie.key IN ( 'LIVEMEMBERS',
                    'FROZEN',
                    'LATESTART',
                    'LIVEMEMBERLOSS',
                    'PT_BOOKINGS',
                    'DD_SALES_TOTAL',
                    'DD_SALES_24_MONTH',
                    'STARTERPACK_REVENUE',
                    'PT_BY_DD_SOLD',
                    'GymIncome',
                    'GRITREVENUE',
                    'STUDIO_REVENUE',
                    'NUTRITION_REVENUE',
                    'ReceptionIncome',
                    'JoinersBudget',
                    'LeaversBudget',
                    'LiveMemberBudget',
                    'TotalRevenueBudget',
                    'TotalRevenue2',
                    'PTBookingBudget',
                    'PTRevenueBudget',
                    'GritRevenueBudget',
                    'StudioRevenueBudget',
                    'NutritionRevenueBudget',
                    'RetailRevenueBudget',
                    'JoiningFee',
                    'AdminFee' )
        AND dat.for_date BETWEEN PARAMS.FromDate AND PARAMS.ToDate )
or (
        -- Movement fields: fields that need to be sum/aggregated in the extract
        fie.key IN ('EXTRA')
        AND (( dat.for_date BETWEEN PARAMS.FromDate AND PARAMS.ToDate2 and PARAMS.FromDate < PARAMS.ToDate2) or (dat.for_date BETWEEN PARAMS.ToDate2 AND PARAMS.ToDate and PARAMS.FromDate > PARAMS.ToDate2) )))
        
 
    
        
    AND c.id IN (:scope)
GROUP BY
    ROLLUP(
    --REGION,
    co.NAME, c.web_name)

