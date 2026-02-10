-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-8560
WITH
    pre_param AS
    (
        SELECT
            CAST(DATE_TRUNC('month', CAST($$CheckDate$$ AS TIMESTAMP)) AS DATE) AS checkDate
    )
    ,
    PARAMS AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST(dateToLongC(TO_CHAR(pre_param.checkDate, 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT)                                      fromdate,
            CAST(dateToLongC(TO_CHAR(CAST((pre_param.checkDate + INTERVAL '1 MONTH') AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS BIGINT) todate
        FROM
            centers c
        CROSS JOIN
            pre_param
    )
SELECT
    CENTERS.ID AS CenterID,
    CASE
        WHEN CENTERS.name IS NULL
        THEN 'Total'
        ELSE CENTERS.name
    END    AS Center,
    A.NAME AS "Regional Manager",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE(((ShowUps.ManualClasses+ShowUps.AutoClasses) / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM((ShowUps.ManualClasses+ShowUps.AutoClasses)) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END AS "%TOTAL SHOWUP CLASSES",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE(((ShowUps.Manualinductions+ShowUps.AutoInductions) / POSITIVEGAIN.totalJoiners)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM((ShowUps.Manualinductions+ShowUps.AutoInductions)) / SUM(POSITIVEGAIN.totalJoiners)*100,'FM9990.00' )||'%'
    END                                    AS "%TOTAL SHOWUP INDUCTIONS",
    SUM(COALESCE(ShowUps.ManualClasses,0)) AS "Manual showup Classes count",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE((ShowUps.ManualClasses / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.ManualClasses) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END                                  AS "% Manual showup Classes",
    SUM(COALESCE(ShowUps.AutoClasses,0)) AS "Auto showup Classes count",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE((ShowUps.AutoClasses / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.AutoClasses) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END                                                                                                                                              AS "% Auto showup Classes",
    SUM(COALESCE(ShowUps.UNIQUE_CL,0))                                                                                                               AS "TOTAL UNIQUE SHOWUP CLASSES",
    SUM(COALESCE(ShowUps.ManualClasses,0) + COALESCE(ShowUps.AutoClasses,0))                                                                         AS "TOTAL SHOWUP CLASSES",
    SUM(COALESCE(resCap.class_capacity, 0))                                                                                                          AS "Club Capacity",
    ROUND((SUM(COALESCE(ShowUps.ManualClasses,0) + COALESCE(ShowUps.AutoClasses,0))/SUM(COALESCE(resCap.class_capacity, 1)))*100, 2)                 AS "Club Capacity show up ratio %",
    SUM(COALESCE(resCap.res_capacity, resCap.act_capacity))                                                                                          AS "Resource Capacity",
    ROUND((SUM(COALESCE(ShowUps.ManualClasses,0) + COALESCE(ShowUps.AutoClasses,0))/SUM(COALESCE(resCap.res_capacity, resCap.act_capacity)))*100, 2) AS "Resource show up ratio %",
    SUM(COALESCE(ShowUps.BookedWeb,0))                                                                                                               AS "BOOKED WEB",
    SUM(COALESCE(ShowUps.BookedOther,0))                                                                                                             AS "BOOKED OTHER",
    SUM(COALESCE(NoShow.num,0))                                                                                                                      AS "No Shows",
    SUM(COALESCE(ShowUps.Manualinductions,0) )                                                                                                       AS "Manual showup Induction count",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE((ShowUps.Manualinductions / POSITIVEGAIN.totalPositive)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.Manualinductions) / SUM(POSITIVEGAIN.totalPositive)*100,'FM9990.00' )||'%'
    END                                     AS "% Manual showup Induction",
    SUM(COALESCE(ShowUps.AutoInductions,0)) AS "Auto showup Induction count" ,
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE((ShowUps.AutoInductions / POSITIVEGAIN.totalPositive)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.AutoInductions) / SUM(POSITIVEGAIN.totalPositive)*100,'FM9990.00' )||'%'
    END                                                                            AS "% Auto showup Induction",
    SUM(COALESCE(ShowUps.Manualinductions,0) + COALESCE(ShowUps.AutoInductions,0)) AS "TOTAL SHOWUP INDUCTIONDS",
    SUM(COALESCE(ShowUps.UNIQUE_IND,0))                                            AS "TOTAL UNIQUE SHOWUP INDUCTIONS",
    SUM(MEMBERS.total)                                                             AS "TOTAL MEMBERS",
    SUM(POSITIVEGAIN.totalJoiners)                                                 AS "New Joiners",
    SUM(POSITIVEGAIN.totalPositive)                                                AS "Net Gain",
    SUM(COALESCE(ShowUps.BookedStaff,0))                                           AS "BOOKED STAFF"
FROM
    CENTERS
    /*get showups */
LEFT JOIN
    (
        SELECT
            bo.CENTER AS CENTER,
            SUM(
                CASE
                    WHEN pa.SHOWUP_INTERFACE_TYPE = 1
                        AND ac.ACTIVITY_GROUP_ID IN (1,202)
                    THEN 1
                    ELSE 0
                END) AS ManualClasses,
            SUM(
                CASE
                    WHEN pa.SHOWUP_INTERFACE_TYPE = 1
                        AND ac.ACTIVITY_GROUP_ID IN (203)
                    THEN 1
                    ELSE 0
                END) AS ManualInductions,
            SUM(
                CASE
                    WHEN pa.SHOWUP_INTERFACE_TYPE != 1
                        AND ac.ACTIVITY_GROUP_ID IN (1,202)
                    THEN 1
                    ELSE 0
                END) AS AutoClasses,
            SUM(
                CASE
                    WHEN pa.SHOWUP_INTERFACE_TYPE != 1
                        AND ac.ACTIVITY_GROUP_ID IN (203)
                    THEN 1
                    ELSE 0
                END) AS AutoInductions,
            SUM(
                CASE
                    WHEN pa.USER_INTERFACE_TYPE = 2
                    THEN 1
                    ELSE 0
                END) AS BookedWeb,
            SUM(
                CASE
                    WHEN pa.USER_INTERFACE_TYPE = 1
                    THEN 1
                    ELSE 0
                END) AS BookedStaff,
            SUM(
                CASE
                    WHEN pa.USER_INTERFACE_TYPE != 2
                    THEN 1
                    ELSE 0
                END) AS BookedOther,
            COUNT( DISTINCT
            CASE
                WHEN ac.ACTIVITY_GROUP_ID IN (1,202)
                THEN pa.PARTICIPANT_CENTER||'p'||pa.PARTICIPANT_ID
                ELSE NULL
            END) AS UNIQUE_CL,
            COUNT( DISTINCT
            CASE
                WHEN ac.ACTIVITY_GROUP_ID IN (203)
                THEN pa.PARTICIPANT_CENTER||'p'||pa.PARTICIPANT_ID
                ELSE NULL
            END) AS UNIQUE_IND
        FROM
            PARTICIPATIONS pa
        JOIN
            PARAMS
        ON
            PARAMS.id = pa.center
        JOIN
            BOOKINGS bo
        ON
            pa.BOOKING_CENTER = bo.CENTER
            AND pa.BOOKING_ID = bo.ID
            AND bo.STARTTIME >= PARAMS.fromdate
            AND bo.STARTTIME < PARAMS.todate
        JOIN
            ACTIVITY ac
        ON
            ac.ID = bo.ACTIVITY
            AND ac.ACTIVITY_GROUP_ID IN (1,202,203)
        WHERE
            pa.STATE = 'PARTICIPATION'
        GROUP BY
            bo.CENTER) ShowUps
ON
    CENTERS.id = ShowUps.CENTER
LEFT JOIN
    (
        SELECT
            bo.CENTER AS CENTER,
            COUNT(*)  AS num
        FROM
            PARTICIPATIONS pa
        JOIN
            PARAMS
        ON
            PARAMS.id = pa.center
        JOIN
            BOOKINGS bo
        ON
            pa.BOOKING_CENTER = bo.CENTER
            AND pa.BOOKING_ID = bo.ID
            AND bo.STARTTIME >= PARAMS.fromdate
            AND bo.STARTTIME < PARAMS.todate
        JOIN
            ACTIVITY ac
        ON
            ac.ID = bo.ACTIVITY
            AND ac.ACTIVITY_GROUP_ID IN (1,202,203)
        WHERE
            pa.STATE = 'CANCELLED'
            AND pa.CANCELATION_REASON = 'NO_SHOW'
        GROUP BY
            bo.CENTER) NoShow
ON
    CENTERS.id = NoShow.CENTER
JOIN
    (
        SELECT
            bo.CENTER                       AS CENTER,
            SUM(brc.maximum_participations) AS res_capacity,
            SUM(ac.max_participants)        AS act_capacity,
            SUM(bo.class_capacity)          AS class_capacity
        FROM
            BOOKINGS bo
        JOIN
            PARAMS
        ON
            PARAMS.id = bo.center
        JOIN
            BOOKING_RESOURCE_USAGE bru
        ON
            bo.ID = bru.BOOKING_ID
            AND bo.CENTER = bru.BOOKING_CENTER
        JOIN
            BOOKING_RESOURCES br
        ON
            br.CENTER = bru.BOOKING_RESOURCE_CENTER
            AND br.ID = bru.BOOKING_RESOURCE_ID
        JOIN
            BOOKING_RESOURCE_CONFIGS brc
        ON
            brc.BOOKING_RESOURCE_CENTER = br.CENTER
            AND brc.BOOKING_RESOURCE_ID = br.ID
        JOIN
            ACTIVITY ac
        ON
            ac.ID = bo.ACTIVITY
            AND ac.ACTIVITY_GROUP_ID IN (1,202)
        WHERE
            bo.state = 'ACTIVE'
            AND bo.STARTTIME >= PARAMS.fromdate
            AND bo.STARTTIME < PARAMS.todate
        GROUP BY
            bo.CENTER) resCap
ON
    CENTERS.id = resCap.CENTER
    /*join for KPI on classes:  FAST Classes and Pure Classes */
JOIN
    (
        SELECT
            kdc.CENTER,
            kdc.VALUE AS Total
        FROM
            KPI_FIELDS kfc
        JOIN
            KPI_DATA kdc
        ON
            kdc.FIELD = kfc.ID
        JOIN
            PARAMS
        ON
            PARAMS.id = kdc.CENTER
        WHERE
            kfc.KEY IN ( 'MEMBERS')
            AND kdc.FOR_DATE = (
                CASE
                    WHEN PARAMS.todate < CAST(dateToLongC(TO_CHAR(now(), 'YYYY-MM-DD HH24:MI') , kdc.CENTER) AS BIGINT)
                    THEN longToDateC(PARAMS.todate, kdc.CENTER)
                    ELSE CAST(DATE_TRUNC('day', CAST(now() AS TIMESTAMP)) AS DATE)-1
                END) ) MEMBERS
ON
    MEMBERS.center = CENTERS.ID
    /*Get the total number of members for the clubs on that day*/
JOIN
    (
        SELECT
            kdc.CENTER,
            SUM (
                CASE kfc.KEY
                    WHEN 'POSITIVEGAIN'
                    THEN kdc.VALUE
                    ELSE 0
                END) AS totalPositive,
            SUM (
                CASE kfc.KEY
                    WHEN 'JOINERS'
                    THEN kdc.VALUE
                    ELSE 0
                END) AS totalJoiners
        FROM
            KPI_FIELDS kfc
        JOIN
            KPI_DATA kdc
        ON
            kdc.FIELD = kfc.ID
        JOIN
            PARAMS
        ON
            PARAMS.id = kdc.center
        WHERE
            kfc.KEY IN ( 'POSITIVEGAIN',
                        'JOINERS')
            AND kdc.FOR_DATE <= longToDateC(PARAMS.todate, kdc.center)
            AND kdc.FOR_DATE >= longToDateC(PARAMS.fromdate, kdc.center)
        GROUP BY
            kdc.CENTER) POSITIVEGAIN
ON
    POSITIVEGAIN.center = CENTERS.ID
JOIN
    AREA_CENTERS AC
ON
    CENTERS.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
    AND A.PARENT = 61
WHERE
    MEMBERS.total > 0
    AND CENTERS.id IN ($$Scope$$)
    AND now() >=
    CASE
        WHEN $$IncludePresale$$= 0
        THEN CENTERS.STARTUPDATE
        ELSE now()
    END
GROUP BY
    grouping sets ( (CENTERS.name,CENTERS.ID,A.NAME), () )
ORDER BY
    1