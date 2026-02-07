 (
 SELECT
     ' Date','Status',
     TO_CHAR(SYSDATE-1,'DD/MM/YYYY')    AS "Day",
     TO_CHAR(SYSDATE-1-1,'DD/MM/YYYY')  AS "Day-1",
     TO_CHAR(SYSDATE-1-2,'DD/MM/YYYY')  AS "Day-2",
     TO_CHAR(SYSDATE-1-3,'DD/MM/YYYY')  AS "Day-3",
     TO_CHAR(SYSDATE-1-4,'DD/MM/YYYY')  AS "Day-4",
     TO_CHAR(SYSDATE-1-5,'DD/MM/YYYY')  AS "Day-5",
     TO_CHAR(SYSDATE-1-6,'DD/MM/YYYY')  AS "Day-6",
     TO_CHAR(SYSDATE-1-7,'DD/MM/YYYY')  AS "Day-7",
     TO_CHAR(SYSDATE-1-8,'DD/MM/YYYY')  AS "Day-8",
     TO_CHAR(SYSDATE-1-9,'DD/MM/YYYY')  AS "Day-9",
     TO_CHAR(SYSDATE-1-10,'DD/MM/YYYY') AS "Day-10",
     TO_CHAR(SYSDATE-1-11,'DD/MM/YYYY') AS "Day-11",
     TO_CHAR(SYSDATE-1-12,'DD/MM/YYYY') AS "Day-12",
     TO_CHAR(SYSDATE-1-13,'DD/MM/YYYY') AS "Day-13",
     TO_CHAR(SYSDATE-1-14,'DD/MM/YYYY') AS "Day-14",
     TO_CHAR(SYSDATE-1-15,'DD/MM/YYYY') AS "Day-15",
     TO_CHAR(SYSDATE-1-16,'DD/MM/YYYY') AS "Day-16",
     TO_CHAR(SYSDATE-1-17,'DD/MM/YYYY') AS "Day-17",
     TO_CHAR(SYSDATE-1-18,'DD/MM/YYYY') AS "Day-18",
     TO_CHAR(SYSDATE-1-19,'DD/MM/YYYY') AS "Day-19",
     TO_CHAR(SYSDATE-1-20,'DD/MM/YYYY') AS "Day-20",
     TO_CHAR(SYSDATE-1-21,'DD/MM/YYYY') AS "Day-21",
     TO_CHAR(SYSDATE-1-22,'DD/MM/YYYY') AS "Day-22",
     TO_CHAR(SYSDATE-1-23,'DD/MM/YYYY') AS "Day-23",
     TO_CHAR(SYSDATE-1-24,'DD/MM/YYYY') AS "Day-24",
     TO_CHAR(SYSDATE-1-25,'DD/MM/YYYY') AS "Day-25",
     TO_CHAR(SYSDATE-1-26,'DD/MM/YYYY') AS "Day-26",
     TO_CHAR(SYSDATE-1-27,'DD/MM/YYYY') AS "Day-27",
     TO_CHAR(SYSDATE-1-28,'DD/MM/YYYY') AS "Day-28",
     TO_CHAR(SYSDATE-1-29,'DD/MM/YYYY') AS "Day-29",
     TO_CHAR(SYSDATE-1-30,'DD/MM/YYYY') AS "Day-30",
     TO_CHAR(SYSDATE-1-31,'DD/MM/YYYY') AS "Day-31"
 FROM
     DUAL)
UNION
    (
        SELECT
            NVL(CENTER,'_Grand Total'),
            C_STATUS as "Status",
            TO_CHAR(SUM("Day")) ,
            TO_CHAR(SUM("Day-1")),
            TO_CHAR(SUM("Day-2")),
            TO_CHAR(SUM("Day-3")),
            TO_CHAR(SUM("Day-4")),
            TO_CHAR(SUM("Day-5")),
            TO_CHAR(SUM("Day-6")),
            TO_CHAR(SUM("Day-7")),
            TO_CHAR(SUM("Day-8")),
            TO_CHAR(SUM("Day-9")),
            TO_CHAR(SUM("Day-10")),
            TO_CHAR(SUM("Day-11")),
            TO_CHAR(SUM("Day-12")),
            TO_CHAR(SUM("Day-13")),
            TO_CHAR(SUM("Day-14")),
            TO_CHAR(SUM("Day-15")),
            TO_CHAR(SUM("Day-16")),
            TO_CHAR(SUM("Day-17")),
            TO_CHAR(SUM("Day-18")),
            TO_CHAR(SUM("Day-19")),
            TO_CHAR(SUM("Day-20")),
            TO_CHAR(SUM("Day-21")),
            TO_CHAR(SUM("Day-22")),
            TO_CHAR(SUM("Day-23")),
            TO_CHAR(SUM("Day-24")),
            TO_CHAR(SUM("Day-25")),
            TO_CHAR(SUM("Day-26")),
            TO_CHAR(SUM("Day-27")),
            TO_CHAR(SUM("Day-28")),
            TO_CHAR(SUM("Day-29")),
            TO_CHAR(SUM("Day-30")),
            TO_CHAR(SUM("Day-31"))
        FROM
            (
                SELECT
                    *
                FROM
                    (
                        SELECT
                            C.NAME AS CENTER,
                            CASE
                                WHEN c.STARTUPDATE>SYSDATE
                                THEN 'Pre-Join'
                                ELSE 'Open'
                            END                                          AS C_STATUS,
                            MC.VALUE                                     AS MEMBERS,
                            TRUNC(SYSDATE-1 -$$offset$$ ,'DDD')-MC.FOR_DATE AS DAYSAGO
                        FROM
                            -- member field
                            KPI_FIELDS MF,
                            CENTERS C
                        LEFT JOIN
                            -- members current
                            KPI_DATA MC
                        ON
                            C.ID = MC.CENTER
                        WHERE
                            MF.KEY = 'MEMBERS'
                            AND C.ID IN ( $$scope$$ )
                            AND MC.FIELD = MF.ID
                            AND MC.VALUE > 0
                            AND MC.FOR_DATE > TRUNC(SYSDATE-33-$$offset$$ ,'DDD') ) PIVOT (SUM(MEMBERS) FOR DAYSAGO IN (0  AS "Day" ,
                                                                                                                     1  AS "Day-1" ,
                                                                                                                     2  AS "Day-2" ,
                                                                                                                     3  AS "Day-3" ,
                                                                                                                     4  AS "Day-4" ,
                                                                                                                     5  AS "Day-5" ,
                                                                                                                     6  AS "Day-6" ,
                                                                                                                     7  AS "Day-7" ,
                                                                                                                     8  AS "Day-8" ,
                                                                                                                     9  AS "Day-9" ,
                                                                                                                     10 AS "Day-10" ,
                                                                                                                     11 AS "Day-11" ,
                                                                                                                     12 AS "Day-12" ,
                                                                                                                     13 AS "Day-13" ,
                                                                                                                     14 AS "Day-14" ,
                                                                                                                     15 AS "Day-15" ,
                                                                                                                     16 AS "Day-16" ,
                                                                                                                     17 AS "Day-17" ,
                                                                                                                     18 AS "Day-18" ,
                                                                                                                     19 AS "Day-19" ,
                                                                                                                     20 AS "Day-20" ,
                                                                                                                     21 AS "Day-21" ,
                                                                                                                     22 AS "Day-22" ,
                                                                                                                     23 AS "Day-23" ,
                                                                                                                     24 AS "Day-24" ,
                                                                                                                     25 AS "Day-25" ,
                                                                                                                     26 AS "Day-26" ,
                                                                                                                     27 AS "Day-27" ,
                                                                                                                     28 AS "Day-28" ,
                                                                                                                     29 AS "Day-29" ,
                                                                                                                     30 AS "Day-30" ,
                                                                                                                     31 AS "Day-31" ) ) ) RES
        
            GROUP BY
    grouping sets ( (CENTER,C_STATUS), () ))