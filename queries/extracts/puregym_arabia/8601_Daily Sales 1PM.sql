-- The extract is extracted from Exerp on 2026-02-08
-- https://puregym.zendesk.com/agent/tickets/453885
Copied from extract 1201 with text adjustments, only necessary for scheduling
SELECT
    e1.*,
    e1."Today's Joiners 1pm"-e1."Today's Leavers 1pm" AS "Today's Net Gain 1pm"
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
                END) AS "Today's Joiners 1pm",
            SUM(
                CASE kf.key
                    WHEN 'TODAYSLEAVERS'
                    THEN kd.value
                    ELSE NULL
                END) AS "Today's Leavers 1pm"
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
            -- Area Saudi Arabia
            AND A.PARENT in (10,2)
        WHERE
            kf.KEY IN ('POSITIVEGAIN',
                       'TODAYSLEAVERS')
            AND kd.for_date = CAST(now() at time zone c.time_zone AS DATE)
            AND c.ID != 100
            and c.id in ($$Scope$$)
        GROUP BY
            grouping sets ( (c.name,A.NAME,C.STARTUPDATE), () )
        ORDER BY
            c.NAME) e1