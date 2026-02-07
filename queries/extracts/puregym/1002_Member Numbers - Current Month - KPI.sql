WITH
    V_EXCLUDED_SUBSCRIPTIONS AS
    (
        SELECT
            ppgl.PRODUCT_CENTER as center,
            ppgl.PRODUCT_ID as id
        FROM
            PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
        JOIN
            PRODUCT_GROUP pg
        ON
            pg.ID = ppgl.PRODUCT_GROUP_ID
        WHERE
            pg.EXCLUDE_FROM_MEMBER_COUNT = True
    )
 SELECT
     COALESCE(CENTER,'Total '|| TO_CHAR(MAX("DATE"),'DD/MM/YYYY')) AS "Club",
 CENTER_ID AS "Club_ID",
     COALESCE(IsOpen,'-')                                          AS "Status",
     COALESCE(REGION,'Grand')                                      AS "Region",
     case REGION when 'Justin Way' then 1 when 'Graeme Penny' then 2 when 'Jake Rostron' then 3 when 'Matt Buckley' then 4 when 'Johanna Brogan' then 5 when 'Matt Tomlinson' then 6 when 'Naj Chekara' then 7 when 'Malcom Armstrong' then 8 when 'Barry Ashby' then 9 when 'Andrew Ingham' then 10 when 'John Maddox' then 11 when 'Jacqui Pope' then 12 end as "Region Number",
     SUM(NETGAIN)                                             AS "Net gain Month",
     SUM(NET_GAIN_YESTERDAY )                                 AS "Net gain yesterday",
     SUM(MONTHNETGAINTARGET)                                  AS "Month net gain target",
     SUM(MONTHNETGAINDIFF)                                    AS "Month net gain difference",
     CASE
         WHEN (add_months(TRUNC(CURRENT_TIMESTAMP -1 -$$offset$$ ,'MM'),1)-TRUNC(CURRENT_TIMESTAMP-1 -$$offset$$ ,'DDD')-1) = 0
         THEN SUM(MONTHNETGAINDIFF)
         ELSE CEIL(SUM(MONTHNETGAINDIFF)/(add_months(TRUNC(CURRENT_TIMESTAMP -1 -$$offset$$ ,'MM'),1)-TRUNC(CURRENT_TIMESTAMP-1 -$$offset$$ ,'DDD')-1) *-1)
     END                         AS "Month Net Gain Req Per Day",
     SUM(MEMBERSSTARTMONTH)      AS "Start of Month",
     SUM(JOINERS)                AS "Joiners",
     SUM(REJOINERS+REINSTATED)   AS "Rejoiners",
     SUM(CANCELS)                AS "Cancels",
     SUM(MEMBERS)                AS "Members closing",
     SUM(FORECAST)               AS "Forecast",
     SUM(DIFF)                   AS "Diff to Forecast",
     SUM(FUTUREMONTHLEAVERS)     AS "This Month Forecast Leavers",
     SUM(FUTURENEXTMONTHLEAVERS) AS "Next Month Forecast Leavers",
     --    SUM(NETGAINTARGET)                                       AS "Net gain target",
     --    AVG(POSITION)           AS "Position"
     SUM(STOPS) AS "Stop Nows"
 FROM
     (
         SELECT
             REPORTDATE,
             A.NAME AS REGION,
             C.NAME AS CENTER,
                         C.ID AS CENTER_ID,
             CASE
                 WHEN stops.stopsnum IS NULL
                 THEN 0
                 ELSE stops.stopsnum
             END AS STOPS,
             CASE
                 WHEN c.STARTUPDATE>CURRENT_TIMESTAMP
                 THEN 'Pre-Join'
                 ELSE 'Open'
             END         AS IsOpen,
             MC.VALUE    AS MEMBERS,
             MC.FOR_DATE AS "Date",
             MS.VALUE    AS MEMBERSSTARTMONTH,
             (
                 SELECT
                     SUM(D.VALUE)
                 FROM
                     KPI_DATA D,
                     KPI_FIELDS F
                 WHERE
                     F.KEY = 'JOINERS'
                     AND D.FIELD = F.ID
                     AND C.ID = D.CENTER
                     AND D.FOR_DATE BETWEEN TRUNC(PARAMS.REPORTDATE,'MM') AND PARAMS.REPORTDATE ) AS JOINERS,
             (
                 SELECT
                     SUM(D.VALUE)
                 FROM
                     KPI_DATA D,
                     KPI_FIELDS F
                 WHERE
                     F.KEY = 'REJOINERS'
                     AND D.FIELD = F.ID
                     AND C.ID = D.CENTER
                     AND D.FOR_DATE BETWEEN TRUNC(PARAMS.REPORTDATE,'MM') AND PARAMS.REPORTDATE ) AS REJOINERS,
             (
                 SELECT
                     SUM(kpid.VALUE)
                 FROM
                     KPI_FIELDS kpif
                 JOIN
                     KPI_DATA kpid
                 ON
                     kpid.FIELD = kpif.ID
                 WHERE
                     kpif.KEY = 'NETGAIN'
                     AND kpid.FOR_DATE = PARAMS.REPORTDATE
                     AND kpid.CENTER = C.ID ) AS NET_GAIN_YESTERDAY,
             (
                 SELECT
                     SUM(kpid.VALUE)
                 FROM
                     KPI_FIELDS kpif
                 JOIN
                     KPI_DATA kpid
                 ON
                     kpid.FIELD = kpif.ID
                 WHERE
                     kpif.KEY = 'FUTUREMONTHLEAVERS'
                     AND kpid.FOR_DATE = PARAMS.REPORTDATE
                     AND kpid.CENTER = C.ID ) AS FUTUREMONTHLEAVERS,
             (
                 SELECT
                     SUM(kpid.VALUE)
                 FROM
                     KPI_FIELDS kpif
                 JOIN
                     KPI_DATA kpid
                 ON
                     kpid.FIELD = kpif.ID
                 WHERE
                     kpif.KEY = 'FUTURENEXTMONTHLEAVERS'
                     AND kpid.FOR_DATE = PARAMS.REPORTDATE
                     AND kpid.CENTER = C.ID ) AS FUTURENEXTMONTHLEAVERS,
             (
                 SELECT
                     SUM(D.VALUE)
                 FROM
                     KPI_DATA D,
                     KPI_FIELDS F
                 WHERE
                     F.KEY = 'REINSTATED'
                     AND D.FIELD = F.ID
                     AND C.ID = D.CENTER
                     AND D.FOR_DATE BETWEEN TRUNC(PARAMS.REPORTDATE,'MM') AND PARAMS.REPORTDATE ) AS REINSTATED,
             (
                 SELECT
                     SUM(D.VALUE)
                 FROM
                     KPI_DATA D,
                     KPI_FIELDS F
                 WHERE
                     F.KEY = 'LOSS'
                     AND D.FIELD = F.ID
                     AND C.ID = D.CENTER
                     AND D.FOR_DATE BETWEEN TRUNC(PARAMS.REPORTDATE,'MM') AND PARAMS.REPORTDATE ) AS CANCELS,
             MC.VALUE-MS.VALUE                                                                    AS NETGAIN,
             COALESCE(MCY.VALUE,0)-COALESCE(MSY.VALUE,0)                                                                  AS NETGAIN_YESTERDAY,
             ROUND(MT.VALUE)-MS.VALUE                                                             AS NETGAINTARGET,
             MC.VALUE-MS.VALUE- ROUND(MT.VALUE)-MS.VALUE                                          AS NETGAINDIFF,
             cast(T.VALUE as numeric)                                                                   AS MONTHNETGAINTARGET,
             MC.VALUE-MS.VALUE-T.VALUE                                                            AS MONTHNETGAINDIFF,
             F.VALUE                                                                              AS FORECAST,
             ROUND(MC.VALUE)-F.VALUE                                                              AS DIFF,
             PARAMS.REPORTDATE                                                                    AS "DATE"
         FROM
             (
                 SELECT
                     TRUNC(CURRENT_TIMESTAMP-1 -$$offset$$ ,'DDD') AS REPORTDATE
                  ) PARAMS,
             -- member field
             KPI_FIELDS MF,
             -- member start field
             KPI_FIELDS MSF,
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
         LEFT JOIN -- target field
             KPI_FIELDS TF
         ON
             TF.KEY = 'SALESTARGET'
         LEFT JOIN -- forecast field
             KPI_FIELDS FF
         ON
             FF.KEY = 'FORECAST'
         LEFT JOIN -- target field
             KPI_FIELDS MTF
         ON
             MTF.KEY = 'MEMBERSTARGET'
         LEFT JOIN
             -- members at start of month
             KPI_DATA MS
         ON
             C.ID = MS.CENTER
         LEFT JOIN
             -- members at start of month
             KPI_DATA MSY
         ON
             C.ID = MSY.CENTER
         LEFT JOIN
             -- members current
             KPI_DATA MC
         ON
             C.ID = MC.CENTER
         LEFT JOIN
             -- members yesterday
             KPI_DATA MCY
         ON
             C.ID = MCY.CENTER
         LEFT JOIN
             -- net gain target
             KPI_DATA T
         ON
             C.ID = T.CENTER
             AND T.FIELD = TF.ID
             AND T.FOR_DATE = MC.FOR_DATE
         LEFT JOIN
             -- members target
             KPI_DATA MT
         ON
             C.ID = MT.CENTER
             AND MT.FIELD = MTF.ID
             AND MT.FOR_DATE = MC.FOR_DATE
         LEFT JOIN
             -- forecast
             KPI_DATA F
         ON
             C.ID = F.CENTER
             AND F.FIELD = FF.ID
             AND F.FOR_DATE = MC.FOR_DATE
         LEFT JOIN
             (
                 SELECT
                     c.id,
                     COUNT(*) AS stopsnum
                 FROM
                     (
                         SELECT
                             TRUNC(CURRENT_TIMESTAMP-1 -$$offset$$ ,'DDD') AS REPORTDATE
                          ) PARAMS,
                     PERSONS p
                 JOIN
                     SUBSCRIPTIONS s
                 ON
                     s.OWNER_ID = p.id
                     AND s.owner_center = p.center
                 JOIN
                     SUBSCRIPTION_CHANGE sc
                 ON
                     sc.OLD_SUBSCRIPTION_CENTER = s.CENTER
                     AND sc.OLD_SUBSCRIPTION_ID = s.ID
                     AND TRUNC(longToDateTZ(sc.CHANGE_TIME, 'Europe/London')) - s.END_DATE < 1
                     AND s.END_DATE <= TRUNC(longToDateTZ(sc.CHANGE_TIME, 'Europe/London'))
                     AND sc.TYPE = 'END_DATE'
                 JOIN
                     SUBSCRIPTIONTYPES st
                 ON
                     s.SUBSCRIPTIONTYPE_CENTER = st.CENTER
                     AND s.SUBSCRIPTIONTYPE_ID = st.ID
                     AND (ST.CENTER, ST.ID) not in (select center, id from V_EXCLUDED_SUBSCRIPTIONS)
                 LEFT JOIN
                     CENTERS c
                 ON
                     c.ID = p.CENTER
                 WHERE
                     p.center IN($$scope$$)
                     AND sc.CHANGE_TIME BETWEEN dateToLongtz(TO_CHAR(TRUNC(PARAMS.REPORTDATE,'MM') , 'YYYY-MM-dd HH24:MI'),'Europe/London') AND dateToLongtz(TO_CHAR(PARAMS.REPORTDATE , 'YYYY-MM-dd HH24:MI'),'Europe/London')
                 GROUP BY
                     c.id ,
                     c.NAME) stops
         ON
             c.id= stops.id
         WHERE
             C.ID IN ($$scope$$)
             AND MF.KEY = 'MEMBERS'
             AND MSF.KEY = 'MEMBERSSTARTMONTH'
             AND MS.FIELD = MSF.ID
             AND MSY.FIELD = MSF.ID
             AND MC.FIELD = MF.ID
             AND MCY.FIELD = MF.ID
             AND MC.FOR_DATE = PARAMS.REPORTDATE
             AND MCY.FOR_DATE = PARAMS.REPORTDATE - 1
             AND MS.FOR_DATE = MC.FOR_DATE
             AND MSY.FOR_DATE = MC.FOR_DATE-1
             AND MC.VALUE > 0
             -- AND MCY.VALUE > 0
         ORDER BY
             C.NAME ) t
 GROUP BY
     grouping sets ( (CENTER,CENTER_ID,IsOpen,REGION), () )
 ORDER BY
     CENTER
