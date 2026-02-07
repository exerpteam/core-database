WITH
    PARAMS AS
    (
        SELECT
            datetolongTZ(TO_CHAR( TRUNC($$CheckDate$$,'MM'), 'YYYY-MM-dd HH24:MI' ),'Europe/London')     fromdate,
            datetolongTZ(TO_CHAR(TRUNC(LAST_DAY($$CheckDate$$)), 'YYYY-MM-dd HH24:MI' ),'Europe/London') todate
        FROM
            dual
    )
SELECT
    CENTERS.ID                                                           AS CenterID,
    DECODE(CENTERS.name, NULL, '--Total', CENTERS.name)                  AS Center,
    A.NAME                                                               AS "Regional Manager",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL(((ShowUps.ManualClasses+ShowUps.AutoClasses) / DECODE(MEMBERS.total,0,1,MEMBERS.total))*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM((ShowUps.ManualClasses+ShowUps.AutoClasses)) / DECODE(SUM(MEMBERS.total),0,1,SUM(MEMBERS.total))*100,'FM9990.00' )||'%'
    END                                                                  AS "%TOTAL SHOWUP CLASSES",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL(((ShowUps.Manualinductions+ShowUps.AutoInductions) / DECODE(POSITIVEGAIN.totalJoiners,0,1,POSITIVEGAIN.totalJoiners))*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM((ShowUps.Manualinductions+ShowUps.AutoInductions)) / DECODE(SUM(POSITIVEGAIN.totalJoiners),0,1,SUM(POSITIVEGAIN.totalJoiners))*100,'FM9990.00' )||'%'
    END                                                                  AS "%TOTAL SHOWUP INDUCTIONS",    
    SUM(NVL(ShowUps.ManualClasses,0))                                    AS "Manual showup Classes count",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL((ShowUps.ManualClasses / DECODE(MEMBERS.total,0,1,MEMBERS.total))*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.ManualClasses) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
    END                                                                  AS "% Manual showup Classes",
    SUM(NVL(ShowUps.AutoClasses,0))                                      AS "Auto showup Classes count",    
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL((ShowUps.AutoClasses / MEMBERS.total)*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.AutoClasses) / DECODE(SUM(MEMBERS.total),0,1,SUM(MEMBERS.total))*100,'FM9990.00' )||'%'
    END                                                                  AS "% Auto showup Classes",
    SUM(NVL(ShowUps.UNIQUE_CL,0))                                        AS "TOTAL UNIQUE SHOWUP CLASSES",
    SUM(NVL(ShowUps.ManualClasses,0) + NVL(ShowUps.AutoClasses,0))       AS "TOTAL SHOWUP CLASSES",
    SUM(NVL(resCap.class_capacity, 0))                                   AS "Club Capacity",
    ROUND((SUM(NVL(ShowUps.ManualClasses,0) + NVL(ShowUps.AutoClasses,0))/SUM(NVL(resCap.class_capacity, 1)))*100, 2)  AS "Club Capacity show up ratio %",
    SUM(NVL(resCap.res_capacity, resCap.act_capacity))                   AS "Resource Capacity",
    ROUND((SUM(NVL(ShowUps.ManualClasses,0) + NVL(ShowUps.AutoClasses,0))/SUM(NVL(resCap.res_capacity, resCap.act_capacity)))*100, 2)  AS  "Resource show up ratio %", 
    SUM(NVL(ShowUps.BookedWeb,0))                                        AS "BOOKED WEB",
    SUM(NVL(ShowUps.BookedOther,0))                                      AS "BOOKED OTHER",            
    SUM(NVL(NoShow.num,0))                                               AS "No Shows",    
    SUM(NVL(ShowUps.Manualinductions,0) )                                AS "Manual showup Induction count",
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL((ShowUps.Manualinductions / DECODE(POSITIVEGAIN.totalPositive,0,1,POSITIVEGAIN.totalPositive))*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.Manualinductions) / DECODE(SUM(POSITIVEGAIN.totalPositive),0,1,SUM(POSITIVEGAIN.totalPositive))*100,'FM9990.00' )||'%'
    END                                                                  AS "% Manual showup Induction",
    SUM(NVL(ShowUps.AutoInductions,0))                                   AS "Auto showup Induction count" ,
    CASE
        WHEN CENTERS.ID IS NOT NULL
        THEN TO_CHAR(SUM(NVL((ShowUps.AutoInductions / DECODE(POSITIVEGAIN.totalPositive,0,1,POSITIVEGAIN.totalPositive))*100,0)),'FM990.00')||'%'
        ELSE TO_CHAR(SUM(ShowUps.AutoInductions) / DECODE(SUM(POSITIVEGAIN.totalPositive),0,1,SUM(POSITIVEGAIN.totalPositive))*100,'FM9990.00' )||'%'
    END                                                                  AS "% Auto showup Induction",
    SUM(NVL(ShowUps.Manualinductions,0) + NVL(ShowUps.AutoInductions,0)) AS "TOTAL SHOWUP INDUCTIONDS",
    SUM(NVL(ShowUps.UNIQUE_IND,0))                                       AS "TOTAL UNIQUE SHOWUP INDUCTIONS",
    SUM(MEMBERS.total)                                                   AS "TOTAL MEMBERS",
    SUM(POSITIVEGAIN.totalJoiners)                                       AS "New Joiners",
    SUM(POSITIVEGAIN.totalPositive)                                      AS "Net Gain",
    SUM(NVL(ShowUps.BookedStaff,0))                                      AS "BOOKED STAFF"
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
                        AND ac.ACTIVITY_GROUP_ID IN (1,202,2601,3601)
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
                        AND ac.ACTIVITY_GROUP_ID IN (1,202,2601,3601)
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
                 count( distinct  CASE
                    WHEN ac.ACTIVITY_GROUP_ID IN (1,202,2601,3601)
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
            AND ac.ACTIVITY_GROUP_ID IN (1,202,203,3601,2601)
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
            AND ac.ACTIVITY_GROUP_ID IN (1,202,203,3601,2601)
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
            bo.CENTER AS CENTER,
            sum(brc.maximum_participations) AS  res_capacity, 
            sum(ac.max_participants)  AS act_capacity,
			sum(bo.class_capacity)  AS class_capacity
        FROM
            PARAMS
        CROSS JOIN
            PUREGYM.BOOKINGS bo
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
            PUREGYM.ACTIVITY ac
        ON
            ac.ID = bo.ACTIVITY
            AND ac.ACTIVITY_GROUP_ID IN (1,202,3601,2601)
        WHERE
		    bo.state = 'ACTIVE'
            AND bo.STARTTIME >= PARAMS.fromdate
            AND bo.STARTTIME < (PARAMS.todate + 86400000)
        GROUP BY
            bo.CENTER) resCap
ON
    CENTERS.id = resCap.CENTER    
    /*join for KPI on classes:  FAST Classes and Standard Classes and Digital Classes */
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
            SUM (decode(kfc.KEY,'POSITIVEGAIN',kdc.VALUE,0)) AS totalPositive,
            SUM (decode(kfc.KEY,'JOINERS',kdc.VALUE,0)) AS totalJoiners
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
            kfc.KEY IN ( 'POSITIVEGAIN','JOINERS')
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
    MEMBERS.total > 0 and a.id not in (145,157,30,147,149)
    AND CENTERS.id IN ($$scope$$)
    AND SYSDATE >=
    CASE
        WHEN  $$IncludePresale$$= 0
        THEN CENTERS.STARTUPDATE
        ELSE SYSDATE
    END
GROUP BY
    grouping sets ( (CENTERS.name,CENTERS.ID,A.NAME), () )
ORDER BY
    