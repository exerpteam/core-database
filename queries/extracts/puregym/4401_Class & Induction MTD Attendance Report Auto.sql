WITH
    PARAMS AS
    (
        SELECT
            CAST(datetolongTZ(TO_CHAR( TRUNC(current_timestamp,'MM'), 'YYYY-MM-dd HH24:MI' ),'Europe/London')  AS BIGINT) AS fromdate,
            CAST(datetolongTZ(TO_CHAR(CAST(DATE_TRUNC('month', current_timestamp) + INTERVAL '1 MONTH' - INTERVAL '1 DAY' AS DATE), 'YYYY-MM-dd HH24:MI' ),'Europe/London') AS BIGINT) AS todate
    )
SELECT
    CENTERS.ID                                                           AS CenterID,
    CASE   WHEN CENTERS.name IS NULL THEN  '-Total'  ELSE CENTERS.name END                  AS Center,
    A.NAME                                                               AS "Regional Manager",
    SUM(COALESCE(ShowUps.ManualClasses,0))                                    AS "Manual showup Classes count",
    SUM(COALESCE(ShowUps.Manualinductions,0) )                                AS "Manual showup Induction count",
    SUM(COALESCE(ShowUps.AutoClasses,0))                                      AS "Auto showup Classes count",
    SUM(COALESCE(ShowUps.AutoInductions,0))                                   AS "Auto showup Induction count" ,
    SUM(COALESCE(ShowUps.ManualClasses,0) + COALESCE(ShowUps.AutoClasses,0))       AS "TOTAL SHOWUP CLASSES",
    SUM(COALESCE(ShowUps.Manualinductions,0) + COALESCE(ShowUps.AutoInductions,0)) AS "TOTAL SHOWUP INDUCTIONDS",
    SUM(COALESCE(ShowUps.BookedWeb,0))                                        AS "BOOKED WEB",
    SUM(COALESCE(ShowUps.BookedOther,0))                                      AS "BOOKED OTHER",
    SUM(MEMBERS.total)                                                   AS MEMBERS,
    SUM(POSITIVEGAIN.totalPositive)                                      AS POSITIVEGAIN,
    SUM(POSITIVEGAIN.totalJoiners)                                      AS NewJoiners,
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE((ShowUps.ManualClasses / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.ManualClasses) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END AS "% Manual showup Classes",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE((ShowUps.Manualinductions / POSITIVEGAIN.totalPositive)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.Manualinductions) / SUM(POSITIVEGAIN.totalPositive)*100,'FM9990.00' )||'%'
    END AS "% Manual showup Induction",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE((ShowUps.AutoClasses / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.AutoClasses) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END AS "% Auto showup Classes",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE((ShowUps.AutoInductions / POSITIVEGAIN.totalJoiners)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.AutoInductions) / SUM(POSITIVEGAIN.totalJoiners)*100,'FM9990.00' )||'%'
    END AS "% Auto showup Induction",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE(((ShowUps.ManualClasses+ShowUps.AutoClasses) / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM((ShowUps.ManualClasses+ShowUps.AutoClasses)) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END AS "%TOTAL SHOWUP CLASSES",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(COALESCE(((ShowUps.Manualinductions+ShowUps.AutoInductions) / POSITIVEGAIN.totalPositive)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM((ShowUps.Manualinductions+ShowUps.AutoInductions)) / SUM(POSITIVEGAIN.totalPositive)*100,'FM9990.00' )||'%'
    END                    AS "%TOTAL SHOWUP INDUCTIONS",
    SUM(COALESCE(NoShow.num,0)) AS "No Shows",
    SUM(COALESCE(ShowUps.UNIQUE_CL,0))                                      AS "TOTAL UNIQUE SHOWUP CLASSES",
    SUM(COALESCE(ShowUps.UNIQUE_IND,0))                                   AS "TOTAL UNIQUE SHOWUP INDUCTIONS"
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
                    WHEN pa.USER_INTERFACE_TYPE != 2
                    THEN 1
                    ELSE 0
                END) AS BookedOther,
                 count( distinct  CASE
                    WHEN ac.ACTIVITY_GROUP_ID IN (1,202)
                    THEN pa.PARTICIPANT_CENTER||'p'||pa.PARTICIPANT_ID
                    ELSE null
                END) as UNIQUE_CL,
                count( distinct  CASE
                    WHEN ac.ACTIVITY_GROUP_ID IN (203)
                    THEN pa.PARTICIPANT_CENTER||'p'||pa.PARTICIPANT_ID
                    ELSE null
                END) as UNIQUE_IND
        FROM
            PARAMS
        CROSS JOIN
            PARTICIPATIONS pa
        JOIN
            BOOKINGS bo
        ON
            pa.BOOKING_CENTER = bo.CENTER
            AND pa.BOOKING_ID = bo.ID
            AND bo.STARTTIME >= PARAMS.fromdate
            AND bo.STARTTIME < (PARAMS.todate + 86400000)
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
            PARAMS
        CROSS JOIN
            PARTICIPATIONS pa
        JOIN
            BOOKINGS bo
        ON
            pa.BOOKING_CENTER = bo.CENTER
            AND pa.BOOKING_ID = bo.ID
            AND bo.STARTTIME >= PARAMS.fromdate
            AND bo.STARTTIME < (PARAMS.todate + 86400000)
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
    /*join for KPI on classes:  FAST Classes and Pure Classes */
JOIN
    (
        SELECT
            kdc.CENTER,
            kdc.VALUE AS Total
        FROM
            KPI_FIELDS kfc
        CROSS JOIN
            PARAMS
        JOIN
            KPI_DATA kdc
        ON
            kdc.FIELD = kfc.ID
            AND kdc.FOR_DATE =
            CASE
                WHEN todate+1000*60*60*24 < datetolongTZ(TO_CHAR(current_timestamp, 'YYYY-MM-dd HH24:MI' ),'Europe/London')
                THEN longtodateTZ(PARAMS.todate, 'Europe/London')
                ELSE TRUNC(current_timestamp-1)
            END
        WHERE
            kfc.KEY IN ( 'MEMBERS')) MEMBERS
ON
    MEMBERS.center = CENTERS.ID
    /*Get the total number of members for the clubs on that day*/
JOIN
    (
        SELECT
            kdc.CENTER,
            SUM (case kfc.KEY when 'POSITIVEGAIN' then kdc.VALUE else 0 end) AS totalPositive,
            SUM (case kfc.KEY when 'JOINERS' then kdc.VALUE else 0 end) AS totalJoiners
        FROM
            KPI_FIELDS kfc
        CROSS JOIN
            PARAMS
        JOIN
            KPI_DATA kdc
        ON
            kdc.FIELD = kfc.ID
            AND kdc.FOR_DATE <= longtodateTZ(PARAMS.todate, 'Europe/London')
            AND kdc.FOR_DATE >= longtodateTZ(PARAMS.fromdate, 'Europe/London')
        WHERE
            kfc.KEY IN ( 'POSITIVEGAIN','JOINERS')
		AND kdc.VALUE != 0 ----avoiding 0 values from new centers
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
    AND CENTERS.id IN ($$scope$$)
    AND current_timestamp >=
    CASE
        WHEN  CAST($$IncludePresale$$ AS INT)= 0
        THEN CENTERS.STARTUPDATE
        ELSE current_timestamp
    END
GROUP BY
    grouping sets ( (CENTERS.name,CENTERS.ID,A.NAME), () )
ORDER BY
    1