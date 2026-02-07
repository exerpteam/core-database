WITH
    PARAMS AS
    (
        SELECT
            datetolongTZ(TO_CHAR( TRUNC(:CheckDate,'MM'), 'YYYY-MM-dd HH24:MI' ),'Europe/London')     fromdate,
            datetolongTZ(TO_CHAR(TRUNC(LAST_DAY(:CheckDate)), 'YYYY-MM-dd HH24:MI' ),'Europe/London') todate
        FROM
            dual
    )
SELECT
    CENTERS.ID                                                           AS CenterID,
    DECODE(CENTERS.name, NULL, '--Total', CENTERS.name)                  AS Center,
    A.NAME                                                               AS "Regional Manager",
    SUM(NVL(ShowUps.ManualClasses,0))                                    AS "Manual showup Classes count",
    SUM(NVL(ShowUps.Manualinductions,0) )                                AS "Manual showup Induction count",
    SUM(NVL(ShowUps.AutoClasses,0))                                      AS "Auto showup Classes count",
    SUM(NVL(ShowUps.AutoInductions,0))                                   AS "Auto showup Induction count" ,
    SUM(NVL(ShowUps.ManualClasses,0) + NVL(ShowUps.AutoClasses,0))       AS "TOTAL SHOWUP CLASSES",
    SUM(NVL(ShowUps.Manualinductions,0) + NVL(ShowUps.AutoInductions,0)) AS "TOTAL SHOWUP INDUCTIONDS",
    SUM(NVL(ShowUps.BookedWeb,0))                                        AS "BOOKED WEB",
    SUM(NVL(ShowUps.BookedOther,0))                                      AS "BOOKED OTHER",
    SUM(MEMBERS.total)                                                   AS MEMBERS,
    SUM(POSITIVEGAIN.totalPositive)                                      AS POSITIVEGAIN,
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL((ShowUps.ManualClasses / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.ManualClasses) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END AS "% Manual showup Classes",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL((ShowUps.Manualinductions / POSITIVEGAIN.totalPositive)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.Manualinductions) / SUM(POSITIVEGAIN.totalPositive)*100,'FM9990.00' )||'%'
    END AS "% Manual showup Induction",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL((ShowUps.AutoClasses / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.AutoClasses) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END AS "% Auto showup Classes",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL((ShowUps.AutoInductions / POSITIVEGAIN.totalPositive)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.AutoInductions) / SUM(POSITIVEGAIN.totalPositive)*100,'FM9990.00' )||'%'
    END AS "% Auto showup Induction",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL(((ShowUps.ManualClasses+ShowUps.AutoClasses) / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM((ShowUps.ManualClasses+ShowUps.AutoClasses)) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END AS "%TOTAL SHOWUP CLASSES",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL(((ShowUps.Manualinductions+ShowUps.AutoInductions) / POSITIVEGAIN.totalPositive)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM((ShowUps.Manualinductions+ShowUps.AutoInductions)) / SUM(POSITIVEGAIN.totalPositive)*100,'FM9990.00' )||'%'
    END                    AS "%TOTAL SHOWUP INDUCTIONS",
    SUM(NVL(NoShow.num,0)) AS "No Shows"
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
                END) AS BookedOther
        FROM
            PARAMS
        CROSS JOIN
            PUREGYM.PARTICIPATIONS pa
        JOIN
            PUREGYM.BOOKINGS bo
        ON
            pa.BOOKING_CENTER = bo.CENTER
            AND pa.BOOKING_ID = bo.ID
            AND bo.STARTTIME >= PARAMS.fromdate
            AND bo.STARTTIME < (PARAMS.todate + 86400000)
        JOIN
            PUREGYM.ACTIVITY ac
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
            PUREGYM.PARTICIPATIONS pa
        JOIN
            PUREGYM.BOOKINGS bo
        ON
            pa.BOOKING_CENTER = bo.CENTER
            AND pa.BOOKING_ID = bo.ID
            AND bo.STARTTIME >= PARAMS.fromdate
            AND bo.STARTTIME < (PARAMS.todate + 86400000)
        JOIN
            PUREGYM.ACTIVITY ac
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
            PUREGYM.KPI_FIELDS kfc
        CROSS JOIN
            PARAMS
        JOIN
            PUREGYM.KPI_DATA kdc
        ON
            kdc.FIELD = kfc.ID
            AND kdc.FOR_DATE =
            CASE
                WHEN todate+1000*60*60*24 < datetolongTZ(TO_CHAR(SYSDATE, 'YYYY-MM-dd HH24:MI' ),'Europe/London')
                THEN longtodateTZ(PARAMS.todate, 'Europe/London')
                ELSE TRUNC(SYSDATE-1)
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
            SUM (kdc.VALUE) AS totalPositive
        FROM
            PUREGYM.KPI_FIELDS kfc
        CROSS JOIN
            PARAMS
        JOIN
            PUREGYM.KPI_DATA kdc
        ON
            kdc.FIELD = kfc.ID
            AND kdc.FOR_DATE <= longtodateTZ(PARAMS.todate, 'Europe/London')
            AND kdc.FOR_DATE >= longtodateTZ(PARAMS.fromdate, 'Europe/London')
        WHERE
            kfc.KEY IN ( 'POSITIVEGAIN')
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
    AND CENTERS.id IN (:scope)
    AND SYSDATE >=
    CASE
        WHEN  :IncludePresale= 0
        THEN CENTERS.STARTUPDATE
        ELSE SYSDATE
    END
GROUP BY
    grouping sets ( (CENTERS.name,CENTERS.ID,A.NAME), () )
ORDER BY
    1