SELECT
Sales.center as "Center Name", 
    Sales.Region as "Region",
    sales.New_precentage as "Joiners %",
    Sales.Cancels_precentage as "Leavers %",
    NetGain.Net_gain_Month as "Net Gain",
    NetGain.Net_gain_target as "Net Gain Target",
    NetGain.Net_gain_difference as "Net Gain Diff",
    Showups.Classes_Precentage as "Classes %",
    showups.Inductions_Precentage as "Inductions %"
FROM
    (
        SELECT
            DECODE(GROUPING(REGION), 1, 'All', REGION)   AS Region ,
            DECODE(GROUPING(CENTER), 1, 'Total', CENTER) AS Center ,
            CASE
                WHEN ((SUM(TB."Total New")+SUM (TB."Total Cancels"))=0)
                THEN 'N/A'
                ELSE ROUND(100*SUM(TB."Total New")/(SUM(TB."Total New")+SUM (TB."Total Cancels")))|| ' %'
            END AS New_precentage,
            CASE
                WHEN ((SUM(TB."Total New")+SUM (TB."Total Cancels"))=0)
                THEN 'N/A'
                ELSE ROUND(100*SUM(TB."Total Cancels")/(SUM(TB."Total New")+SUM (TB."Total Cancels"))) || ' %'
            END AS Cancels_precentage
        FROM
            (
                SELECT
                    A.NAME AS REGION,
                    C.NAME AS CENTER,
                    (
                        SELECT
                            SUM(D.VALUE)
                        FROM
                            KPI_DATA D,
                            KPI_FIELDS F
                        WHERE
                            F.KEY = 'POSITIVEGAIN'
                            AND D.FIELD = F.ID
                            AND C.ID = D.CENTER
                            AND D.FOR_DATE BETWEEN P.STARTDATE AND LAST_DAY(P.STARTDATE) ) AS "Total New" ,
                    (
                        SELECT
                            -SUM(D.VALUE)
                        FROM
                            KPI_DATA D,
                            KPI_FIELDS F
                        WHERE
                            F.KEY = 'LOSS'
                            AND D.FIELD = F.ID
                            AND C.ID = D.CENTER
                            AND D.FOR_DATE BETWEEN P.STARTDATE AND LAST_DAY(P.STARTDATE) ) AS "Total Cancels" ,
                    (
                        SELECT
                            SUM(D.VALUE)
                        FROM
                            KPI_DATA D,
                            KPI_FIELDS F
                        WHERE
                            F.KEY = 'NETGAIN'
                            AND D.FIELD = F.ID
                            AND C.ID = D.CENTER
                            AND D.FOR_DATE BETWEEN P.STARTDATE AND LAST_DAY(P.STARTDATE) ) AS "Total Net Gain" ,
                    "NEW"."1"                                                              AS "1st - New",
                    "LOSS"."1"                                                             AS "1st - Cancels" ,
                    "NEW"."1" -"LOSS"."1"                                                  AS "1st - Net gains",
                    "NEW"."2"                                                              AS "2nd - New",
                    "LOSS"."2"                                                             AS "2nd - Cancels",
                    "NEW"."2" - "LOSS"."2"                                                 AS"2nd - Net gains",
                    "NEW"."3"                                                              AS "3rd - New",
                    "LOSS"."3"                                                             AS "3rd - Cancels",
                    "NEW"."3" -"LOSS"."3"                                                  AS"3rd - Net gains",
                    "NEW"."4"                                                              AS "4th - New",
                    "LOSS"."4"                                                             AS "4th - Cancels",
                    "NEW"."4" -"LOSS"."4"                                                  AS"4th - Net gains",
                    "NEW"."5"                                                              AS "5th - New",
                    "LOSS"."5"                                                             AS "5th - Cancels",
                    "NEW"."5"-"LOSS"."5"                                                   AS"5th - Net gains",
                    "NEW"."6"                                                              AS "6th - New",
                    "LOSS"."6"                                                             AS "6th - Cancels",
                    "NEW"."6" -"LOSS"."6"                                                  AS"6th - Net gains",
                    "NEW"."7"                                                              AS "7th - New",
                    "LOSS"."7"                                                             AS "7th - Cancels",
                    "NEW"."7" -"LOSS"."7"                                                  AS "7th - Net gains",
                    "NEW"."8"                                                              AS "8th - New",
                    "LOSS"."8"                                                             AS"8th - Cancels",
                    "NEW"."8"- "LOSS"."8"                                                  AS "8th - Net gains",
                    "NEW"."9"                                                              AS "9th - New",
                    "LOSS"."9"                                                             AS "9th - Cancels",
                    "NEW"."9" -"LOSS"."9"                                                  AS "9th - Net gains",
                    "NEW"."10"                                                             AS "10th - New",
                    "LOSS"."10"                                                            AS"10th - Cancels",
                    "NEW"."10" -"LOSS"."10"                                                AS"10th - Net gains",
                    "NEW"."11"                                                             AS"11th - New",
                    "LOSS"."11"                                                            AS "11th - Cancels",
                    "NEW"."11" -"LOSS"."11"                                                AS "11th - Net gains",
                    "NEW"."12"                                                             AS"12th - New",
                    "LOSS"."12"                                                            AS"12th - Cancels",
                    "NEW"."12" -"LOSS"."12"                                                AS"12th - Net gains",
                    "NEW"."13"                                                             AS "13th - New",
                    "LOSS"."13"                                                            AS"13th - Cancels",
                    "NEW"."13" -"LOSS"."13"                                                AS"13th - Net gains",
                    "NEW"."14"                                                             AS"14th - New",
                    "LOSS"."14"                                                            AS "14th - Cancels",
                    "NEW"."14" -"LOSS"."14"                                                AS "14th - Net gains",
                    "NEW"."15"                                                             AS"15th - New",
                    "LOSS"."15"                                                            AS"15th - Cancels",
                    "NEW"."15" -"LOSS"."15"                                                AS"15th - Net gains",
                    "NEW"."16"                                                             AS "16th - New",
                    "LOSS"."16"                                                            AS"16th - Cancels",
                    "NEW"."16" -"LOSS"."16"                                                AS"16th - Net gains",
                    "NEW"."17"                                                             AS"17th - New",
                    "LOSS"."17"                                                            AS "17th - Cancels",
                    "NEW"."17" -"LOSS"."17"                                                AS "17th - Net gains",
                    "NEW"."18"                                                             AS"18th - New",
                    "LOSS"."18"                                                            AS"18th - Cancels",
                    "NEW"."18" -"LOSS"."18"                                                AS"18th - Net gains",
                    "NEW"."19"                                                             AS "19th - New",
                    "LOSS"."19"                                                            AS"19th - Cancels",
                    "NEW"."19" -"LOSS"."19"                                                AS"19th - Net gains",
                    "NEW"."20"                                                             AS"20th - New",
                    "LOSS"."20"                                                            AS "20th - Cancels",
                    "NEW"."20" -"LOSS"."20"                                                AS "20th - Net gains",
                    "NEW"."21"                                                             AS"21st - New",
                    "LOSS"."21"                                                            AS"21st - Cancels",
                    "NEW"."21" -"LOSS"."21"                                                AS"21st - Net gains",
                    "NEW"."22"                                                             AS "22nd - New",
                    "LOSS"."22"                                                            AS"22nd - Cancels",
                    "NEW"."22" -"LOSS"."22"                                                AS"22nd - Net gains",
                    "NEW"."23"                                                             AS"23th - New",
                    "LOSS"."23"                                                            AS "23th - Cancels",
                    "NEW"."23" -"LOSS"."23"                                                AS "23th - Net gains",
                    "NEW"."24"                                                             AS"24th - New",
                    "LOSS"."24"                                                            AS"24th - Cancels",
                    "NEW"."24" -"LOSS"."24"                                                AS"24th - Net gains",
                    "NEW"."25"                                                             AS "25th - New",
                    "LOSS"."25"                                                            AS"25th - Cancels",
                    "NEW"."25" -"LOSS"."25"                                                AS"25th - Net gains",
                    "NEW"."26"                                                             AS"26th - New",
                    "LOSS"."26"                                                            AS "26th - Cancels",
                    "NEW"."26" -"LOSS"."26"                                                AS "26th - Net gains",
                    "NEW"."27"                                                             AS"27th - New",
                    "LOSS"."27"                                                            AS"27th - Cancels",
                    "NEW"."27" -"LOSS"."27"                                                AS"27th - Net gains",
                    "NEW"."28"                                                             AS "28th - New",
                    "LOSS"."28"                                                            AS"28th - Cancels",
                    "NEW"."28" -"LOSS"."28"                                                AS"28th - Net gains",
                    "NEW"."29"                                                             AS"29th - New",
                    "LOSS"."29"                                                            AS "29th - Cancels",
                    "NEW"."29" -"LOSS"."29"                                                AS "29th - Net gains",
                    "NEW"."30"                                                             AS"30th - New",
                    "LOSS"."30"                                                            AS"30th - Cancels",
                    "NEW"."30" -"LOSS"."30"                                                AS"30th - Net gains",
                    "NEW"."31"                                                             AS "31st - New",
                    "LOSS"."31"                                                            AS"31st - Cancels",
                    "NEW"."31" -"LOSS"."31"                                                AS"31st - Net gains"
                FROM
                    (
                        SELECT
                            TRUNC(SYSDATE-1 -:offset ,'MM') AS STARTDATE
                        FROM
                            DUAL ) P,
                    CENTERS C
                JOIN
                    AREA_CENTERS AC
                ON
                    C.ID = AC.CENTER
                JOIN
                    AREAS A
                ON
                    A.ID = AC.AREA
                    -- Area Managers/UK
                    AND A.PARENT = 61
                JOIN
                    (
                        SELECT
                            MC.CENTER                         AS CENTER,
                            MC.VALUE                          AS MEMBERS,
                            TRUNC(MC.FOR_DATE- P.STARTDATE)+1 AS "DAY"
                        FROM
                            (
                                SELECT
                                    TRUNC(SYSDATE-1 -:offset ,'MM') AS STARTDATE
                                FROM
                                    DUAL ) P,
                            -- member field
                            KPI_FIELDS MF
                        JOIN
                            -- members current
                            KPI_DATA MC
                        ON
                            MC.FIELD = MF.ID
                        WHERE
                            MF.KEY = 'POSITIVEGAIN'
                            AND MC.FOR_DATE >= P.STARTDATE) PIVOT (SUM(MEMBERS) FOR "DAY" IN (1,
                                                                                              2,
                                                                                              3,
                                                                                              4,
                                                                                              5,
                                                                                              6,
                                                                                              7,
                                                                                              8,
                                                                                              9,
                                                                                              10,
                                                                                              11,
                                                                                              12,
                                                                                              13,
                                                                                              14,
                                                                                              15,
                                                                                              16,
                                                                                              17,
                                                                                              18,
                                                                                              19,
                                                                                              20,
                                                                                              21,
                                                                                              22,
                                                                                              23,
                                                                                              24,
                                                                                              25,
                                                                                              26,
                                                                                              27,
                                                                                              28,
                                                                                              29,
                                                                                              30,
                                                                                              31) ) "NEW"
                ON
                    C.ID ="NEW".CENTER
                JOIN
                    (
                        SELECT
                            MC.CENTER                         AS CENTER,
                            -MC.VALUE                         AS MEMBERS,
                            TRUNC(MC.FOR_DATE- P.STARTDATE+1) AS "DAY"
                        FROM
                            (
                                SELECT
                                    TRUNC(SYSDATE-1 -:offset ,'MM') AS STARTDATE
                                FROM
                                    DUAL ) P,
                            -- member field
                            KPI_FIELDS MF
                        JOIN
                            -- members current
                            KPI_DATA MC
                        ON
                            MC.FIELD = MF.ID
                        WHERE
                            MF.KEY = 'LOSS'
                            AND MC.FOR_DATE >= P.STARTDATE ) PIVOT (SUM(MEMBERS) FOR "DAY" IN (1,
                                                                                               2,
                                                                                               3,
                                                                                               4,
                                                                                               5,
                                                                                               6,
                                                                                               7,
                                                                                               8,
                                                                                               9,
                                                                                               10,
                                                                                               11,
                                                                                               12,
                                                                                               13,
                                                                                               14,
                                                                                               15,
                                                                                               16,
                                                                                               17,
                                                                                               18,
                                                                                               19,
                                                                                               20,
                                                                                               21,
                                                                                               22,
                                                                                               23,
                                                                                               24,
                                                                                               25,
                                                                                               26,
                                                                                               27,
                                                                                               28,
                                                                                               29,
                                                                                               30,
                                                                                               31) ) "LOSS"
                ON
                    C.ID = "LOSS".CENTER
                WHERE
                    (
                        SELECT
                            SUM(D.VALUE)
                        FROM
                            KPI_DATA D,
                            KPI_FIELDS F
                        WHERE
                            F.KEY = 'POSITIVEGAIN'
                            AND D.FIELD = F.ID
                            AND C.ID = D.CENTER
                            AND D.FOR_DATE BETWEEN P.STARTDATE AND LAST_DAY(P.STARTDATE) ) > 0
                    AND C.ID IN ( :scope ) ) TB
        GROUP BY
            ROLLUP (REGION,CENTER)) sales
JOIN
    (
        SELECT
            NVL(REGION,'Grand') AS Region,
            NVL(CENTER,'Total') AS Center,
            SUM(NETGAIN)        AS Net_gain_Month,
            SUM(NETGAINTARGET)  AS Net_gain_target,
            SUM(NETGAINDIFF)    AS Net_gain_difference
        FROM
            (
                SELECT
                    A.NAME                                                                         AS REGION,
                    C.NAME                                                                         AS CENTER,
                    MS.VALUE                                                                       AS MEMBERS,
                    MC.VALUE-MS.VALUE                                                              AS NETGAIN,
                    TRUNC(MT.VALUE-MS.VALUE)                                                       AS NETGAINTARGET,
                    MC.VALUE-MS.VALUE- TRUNC(MT.VALUE-MS.VALUE)                                    AS NETGAINDIFF,
                    TO_NUMBER(T.VALUE)                                                             AS MONTHNETGAINTARGET,
                    MC.VALUE-MS.VALUE-T.VALUE                                                      AS MONTHNETGAINDIFF,
                    ROW_NUMBER() OVER (ORDER BY MC.VALUE-MS.VALUE- TRUNC(MT.VALUE-MS.VALUE) DESC ) AS POSITION
                FROM
                    KPI_FIELDS MF,
                    KPI_FIELDS TF,
                    KPI_FIELDS MSF,
                    KPI_FIELDS MTF,
                    CENTERS C
                JOIN
                    AREA_CENTERS AC
                ON
                    C.ID = AC.CENTER
                JOIN
                    AREAS A
                ON
                    A.ID = AC.AREA
                    AND A.PARENT = 61
                LEFT JOIN
                    KPI_DATA MS
                ON
                    C.ID = MS.CENTER
                LEFT JOIN
                    KPI_DATA MC
                ON
                    C.ID = MC.CENTER
                LEFT JOIN
                    KPI_DATA T
                ON
                    C.ID = T.CENTER
                LEFT JOIN
                    KPI_DATA MT
                ON
                    C.ID = MT.CENTER
                WHERE
                    C.ID IN ( :scope )
                    AND MC.VALUE > 0
                    AND MF.KEY = 'MEMBERS'
                    AND MSF.KEY = 'MEMBERSSTARTMONTH'
                    AND MTF.KEY = 'MEMBERSTARGET'
                    AND TF.KEY = 'SALESTARGET'
                    AND MS.FIELD = MSF.ID
                    AND MC.FIELD = MF.ID
                    AND MT.FIELD = MTF.ID
                    AND MC.FOR_DATE = TRUNC(SYSDATE-1-0 ,'DDD')
                    AND T.FOR_DATE = MC.FOR_DATE
                    AND MS.FOR_DATE = MC.FOR_DATE
                    AND MT.FOR_DATE = MC.FOR_DATE
                    AND T.FIELD = TF.ID
                ORDER BY
                    MC.VALUE-MS.VALUE- TRUNC(MT.VALUE-MS.VALUE) DESC)
        GROUP BY
            ROLLUP(REGION,CENTER)) NetGain
ON
    sales.region = NetGain.Region
    AND sales.center = NetGain.center
JOIN
    (
        WITH
            PARAMS AS
            (
                SELECT
                    datetolongTZ(TO_CHAR( TRUNC(SYSDATE,'MM'), 'YYYY-MM-dd HH24:MI' ),'Europe/London')     fromdate,
                    datetolongTZ(TO_CHAR(TRUNC(LAST_DAY(SYSDATE)), 'YYYY-MM-dd HH24:MI' ),'Europe/London') todate
                FROM
                    dual
            )
        SELECT
            CENTERS.ID                                        AS CenterID,
            DECODE(CENTERS.name, NULL, 'Total', CENTERS.name) AS Center,
            A.NAME                                            AS Region,
            CASE
                WHEN CENTERS.ID IS NOT NULL
                THEN TO_CHAR(SUM(NVL(((ShowUps.ManualClasses+ShowUps.AutoClasses) / MEMBERS.total)*100,0)),'FM990.00')||'%'
                ELSE TO_CHAR(SUM((ShowUps.ManualClasses+ShowUps.AutoClasses)) / SUM(MEMBERS.total)*100,'FM9990.00' )||'%'
            END AS Classes_Precentage,
            CASE
                WHEN CENTERS.ID IS NOT NULL
                THEN TO_CHAR(SUM(NVL(((ShowUps.Manualinductions+ShowUps.AutoInductions) / POSITIVEGAIN.totalPositive)*100,0)),'FM990.00')||'%'
                ELSE TO_CHAR(SUM((ShowUps.Manualinductions+ShowUps.AutoInductions)) / SUM(POSITIVEGAIN.totalPositive)*100,'FM9990.00' )||'%'
            END AS Inductions_Precentage
        FROM
            CENTERS
            /*get showups */
        LEFT JOIN
            (
                SELECT
                    bo.CENTER AS CENTER,
                    SUM(
                        CASE
                            WHEN pa.USER_INTERFACE_TYPE = 1
                                AND ac.ACTIVITY_GROUP_ID IN (1,202)
                            THEN 1
                            ELSE 0
                        END) AS ManualClasses,
                    SUM(
                        CASE
                            WHEN pa.USER_INTERFACE_TYPE = 1
                                AND ac.ACTIVITY_GROUP_ID IN (203)
                            THEN 1
                            ELSE 0
                        END) AS ManualInductions,
                    SUM(
                        CASE
                            WHEN pa.USER_INTERFACE_TYPE != 1
                                AND ac.ACTIVITY_GROUP_ID IN (1,202)
                            THEN 1
                            ELSE 0
                        END) AS AutoClasses,
                    SUM(
                        CASE
                            WHEN pa.USER_INTERFACE_TYPE != 1
                                AND ac.ACTIVITY_GROUP_ID IN (203)
                            THEN 1
                            ELSE 0
                        END) AS AutoInductions
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
                WHEN :IncludePresale = 0
                THEN CENTERS.STARTUPDATE
                ELSE SYSDATE
            END
        GROUP BY
            grouping sets ( (CENTERS.name,CENTERS.ID,A.NAME), () )
        ORDER BY
            1) Showups
ON
    showups.region = sales.region
    AND showups.center=sales.center