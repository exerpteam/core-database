SELECT
    NVL(REGION,'Grand')     AS "Region",
    NVL(CENTER,'Total')     AS "Center",
    C_STATUS as "Status",
    SUM(NETGAIN)            AS "Net gain Month",
    SUM(MONTHNETGAINTARGET) AS "Month net gain target",
    SUM(MONTHNETGAINDIFF)   AS "Month net gain difference",
    CASE
        WHEN CENTER IS null 
        THEN null
        ELSE AVG(POSITION)
    END AS "Position"
FROM
    (
   
        SELECT
            A.NAME   AS REGION,
            C.NAME   AS CENTER,
            CASE
                WHEN c.STARTUPDATE>SYSDATE
                THEN 'Pre-Join'
                ELSE 'Open'
            END             AS C_STATUS,
            MS.VALUE AS MEMBERS,
            MC.VALUE-MS.VALUE                                  AS NETGAIN,
            TO_NUMBER(T.VALUE)                                                AS MONTHNETGAINTARGET,
            MC.VALUE-MS.VALUE-T.VALUE                                           AS MONTHNETGAINDIFF,
			/*
            ROW_NUMBER() OVER (ORDER BY MC.VALUE-MS.VALUE- TRUNC(MT.VALUE-MS.VALUE) DESC ) AS
            POSITION,*/
            ROW_NUMBER() OVER (ORDER BY MC.VALUE-MS.VALUE-T.VALUE  DESC ) AS
            POSITION
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
        AND MC.FOR_DATE = TRUNC(SYSDATE-1-:offset ,'DDD')
        AND T.FOR_DATE = MC.FOR_DATE
        AND MS.FOR_DATE = MC.FOR_DATE
        AND MT.FOR_DATE = MC.FOR_DATE
        AND T.FIELD = TF.ID
        ORDER BY
            MC.VALUE-MS.VALUE- TRUNC(MT.VALUE-MS.VALUE) DESC)
    GROUP BY
    grouping sets ( (REGION,CENTER,C_STATUS), () )