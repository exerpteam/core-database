-- The extract is extracted from Exerp on 2026-02-08
--  
-- KPI needs to setup and then KPI field value need to update in this extract. Also check area parent = 61?
SELECT
    e1.*,
    e1."Today's Joiners 12pm"-e1."Today's Leavers 12pm" AS "Today's Net Gain 12pm"
FROM
    (
        SELECT
            CASE 
                WHEN c.NAME IS NULL
                THEN 'Grand Total'
                ELSE c.name
            END AS "Center Name",
            CASE
                WHEN c.STARTUPDATE>now()
                THEN 'Pre-Join'
                WHEN C.STARTUPDATE IS NULL
                THEN NULL
                ELSE 'Open'
            END    AS "Center Status",
            a.name AS "Region",
            SUM(
                CASE kf.key
                    WHEN 'POSITIVEGAIN'
                    THEN kd.value
                    ELSE NULL
                END) AS "Today's Joiners 12pm",
            SUM(
                CASE kf.key
                    WHEN 'TODAYSLEAVERS'
                    THEN kd.value
                    ELSE NULL
                END) AS "Today's Leavers 12pm"
        FROM
            KPI_DATA kd
        JOIN
            kpi_fields kf
        ON
            kd.FIELD = kf.ID
        JOIN
            CENTERS c
        ON
            c.id = kd.CENTER
        JOIN
            AREA_CENTERS AC
        ON
            c.ID = AC.CENTER
        JOIN
            AREAS A
        ON
            A.ID = AC.AREA
            -- Area US
            AND A.PARENT in (7,8,2)
        WHERE
            kf.KEY IN ('POSITIVEGAIN',
                       'TODAYSLEAVERS')
            AND kd.for_date = CAST(now() AS DATE)
            AND c.ID != 100
        GROUP BY
            grouping sets ( (c.name,A.NAME,C.STARTUPDATE), () )
        ORDER BY
            c.NAME) e1