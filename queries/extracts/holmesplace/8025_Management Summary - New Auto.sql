

WITH
    PARAMS AS
    (
        SELECT
            CASE
                WHEN $$Last_month$$ = 0
                THEN date_trunc('month',par.ParamDate)
                ELSE date_trunc('month',par.ParamDate) - interval '1 month'
            END AS FromDate,
            CASE
                WHEN $$Last_month$$ = 0
                THEN par.ParamDate
                ELSE date_trunc('month',par.ParamDate)
            END AS ToDate
        FROM
            (
                SELECT
                    date_trunc('day' ,CURRENT_DATE - 1 -$$offset$$) AS ParamDate) par
    )
SELECT
    COALESCE(co.NAME, 'Holmes Place Europe') AS "Country",
    COALESCE(c.WEB_NAME, 'Total '|| co.Name) AS "Club",
    SUM(
        CASE fie.key
            WHEN 'NETGAIN'
            THEN dat.value
            ELSE 0
        END) AS NetGain,
    SUM(
        CASE
            WHEN fie.key = 'MEMBERS'
                AND for_date = PARAMS.FromDate - interval '1 day'
            THEN dat.value
            ELSE 0
        END) AS Opening,
    SUM(
        CASE fie.key
            WHEN 'JOINERS'
            THEN dat.value
            ELSE 0
        END) AS Joiners,
    SUM(
        CASE fie.key
            WHEN 'REJOINERS'
            THEN dat.value
            ELSE 0
        END) AS Rejoiners,
    SUM(
        CASE fie.key
            WHEN 'LIVEMEMBERLOSS'
            THEN dat.value
            ELSE 0
        END) AS Leavers,
    SUM(
        CASE fie.key
            WHEN 'LMPOSITIVEGAINOTHER'
            THEN dat.value
            ELSE 0
        END) AS Other,
    SUM(
        CASE
            WHEN fie.key = 'MEMBERS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS Closing,
    -SUM(
        CASE
            WHEN fie.key = 'MEMBERDEBTORS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS Debtors,
    -SUM(
        CASE
            WHEN fie.key = 'LATESTART'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS LateStart,
    -SUM(
        CASE
            WHEN fie.key = 'FROZEN'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS Frozen,
    -SUM(
        CASE
            WHEN fie.key = 'EXTRA'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS Extra,
    -SUM(
        CASE
            WHEN fie.key = 'KIDS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS Kids,
    SUM(
        CASE
            WHEN fie.key = 'LIVEMEMBERS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS LiveMembers,
    SUM(
        CASE
            WHEN fie.key = 'LIVEMEMBERS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) - SUM(
        CASE
            WHEN fie.key = 'LIVEMEMBERS'
                AND for_date = PARAMS.FromDate - interval '1 day'
            THEN dat.value
            ELSE 0
        END) AS "LIVE MEMBERS net gain",
    SUM(
        CASE
            WHEN fie.key = 'COMPS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) AS Comps,
    SUM(
        CASE
            WHEN fie.key = 'COMPS'
                AND for_date = PARAMS.ToDate
            THEN dat.value
            ELSE 0
        END) - SUM(
        CASE
            WHEN fie.key = 'COMPS'
                AND for_date = PARAMS.FromDate - interval '1 day'
            THEN dat.value
            ELSE 0
        END) AS "COMPS net gain"
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
    ((
            fie.key IN ('MEMBERS',
                        'COMPS',
                        'EXTRA',
                        'MEMBERDEBTORS',
                        'FROZEN',
                        'LATESTART',
                        'KIDS',
                        'LIVEMEMBERS')
            AND (
                dat.for_date = PARAMS.FromDate - interval '1 day'
                OR dat.for_date = PARAMS.ToDate) )
        OR (
            -- Movement fields
            fie.key IN ( 'LMPOSITIVEGAIN',
                        'JOINERS',
                        'REJOINERS',
                        'LMPOSITIVEGAINOTHER',
                        'NETGAIN',
                        'LIVEMEMBERLOSS' )
            AND dat.for_date BETWEEN PARAMS.FromDate AND PARAMS.ToDate ))
GROUP BY
    ROLLUP(
    --REGION,
    co.NAME, c.web_name)

