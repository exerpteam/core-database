-- The extract is extracted from Exerp on 2026-02-08
--  
 (
 SELECT
     ' Center Name'                                  AS "Center Name",
     'Startup Date'                                 AS "Startup Date",
     'Regional Manager'                             AS "Regional Manager",
     'Status'                                       AS "Status",
     'From Price £'                                 AS "From Price £",
     'Center Name'                                  AS "To Price £",
     TO_CHAR(TRUNC(SYSDATE,'MM'),'DD/MM/YYYY')      AS "Day-1",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+2,'DD/MM/YYYY')  AS "Day-2",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+3,'DD/MM/YYYY')  AS "Day-3",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+4,'DD/MM/YYYY')  AS "Day-4",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+5,'DD/MM/YYYY')  AS "Day-5",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+6,'DD/MM/YYYY')  AS "Day-6",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+7,'DD/MM/YYYY')  AS "Day-7",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+8,'DD/MM/YYYY')  AS "Day-8",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+9,'DD/MM/YYYY')  AS "Day-9",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+10,'DD/MM/YYYY') AS "Day-10",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+11,'DD/MM/YYYY') AS "Day-11",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+12,'DD/MM/YYYY') AS "Day-12",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+13,'DD/MM/YYYY') AS "Day-13",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+14,'DD/MM/YYYY') AS "Day-14",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+15,'DD/MM/YYYY') AS "Day-15",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+16,'DD/MM/YYYY') AS "Day-16",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+17,'DD/MM/YYYY') AS "Day-17",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+18,'DD/MM/YYYY') AS "Day-18",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+19,'DD/MM/YYYY') AS "Day-19",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+20,'DD/MM/YYYY') AS "Day-20",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+21,'DD/MM/YYYY') AS "Day-21",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+22,'DD/MM/YYYY') AS "Day-22",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+23,'DD/MM/YYYY') AS "Day-23",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+24,'DD/MM/YYYY') AS "Day-24",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+25,'DD/MM/YYYY') AS "Day-25",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+26,'DD/MM/YYYY') AS "Day-26",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+27,'DD/MM/YYYY') AS "Day-27",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+28,'DD/MM/YYYY') AS "Day-28",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+29,'DD/MM/YYYY') AS "Day-29",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+30,'DD/MM/YYYY') AS "Day-30",
     TO_CHAR(TRUNC(SYSDATE,'MM')-1+31,'DD/MM/YYYY') AS "Day-31",
     'Total'                                        AS TOTAL
 FROM
     DUAL)
UNION
    (
SELECT
NVL(name,'_Grand Total') as Name,
STARTUPDATE,
                    General_Manager,
                    IsOpen,
                    From_Price,
                    To_Price,
     TO_CHAR( SUM("Day-1")) AS "day-1",
           TO_CHAR( SUM("Day-2")) AS "Day-2",
           TO_CHAR( SUM("Day-3")) AS "Day-3",
           TO_CHAR( SUM("Day-4")) AS "Day-4",
           TO_CHAR( SUM("Day-5")) AS "Day-5",
           TO_CHAR( SUM("Day-6")) AS "Day-6",
           TO_CHAR( SUM("Day-7")) AS "Day-7",
           TO_CHAR( SUM("Day-8")) AS "Day-8",
           TO_CHAR( SUM("Day-9")) AS "Day-9",
           TO_CHAR( SUM("Day-10")) AS "Day-10",
           TO_CHAR( SUM("Day-11")) AS "Day-11",
           TO_CHAR( SUM("Day-12")) AS "Day-12",
           TO_CHAR( SUM("Day-13")) AS "Day-13",
           TO_CHAR( SUM("Day-14")) AS "Day-14",
           TO_CHAR( SUM("Day-15")) AS "Day-15",
           TO_CHAR( SUM("Day-16")) AS "Day-16",
           TO_CHAR( SUM("Day-17")) AS "Day-17",
           TO_CHAR( SUM("Day-18")) AS "Day-18",
           TO_CHAR( SUM("Day-19")) AS "Day-19",
           TO_CHAR( SUM("Day-20")) AS "Day-20",
           TO_CHAR( SUM("Day-21")) AS "Day-21",
           TO_CHAR( SUM("Day-22")) AS "Day-22",
           TO_CHAR( SUM("Day-23")) AS "Day-23",
           TO_CHAR( SUM("Day-24")) AS "Day-24",
           TO_CHAR( SUM("Day-25")) AS "Day-25",
           TO_CHAR( SUM("Day-26")) AS "Day-26",
           TO_CHAR( SUM("Day-27")) AS "Day-27",
           TO_CHAR( SUM("Day-28")) AS "Day-28",
           TO_CHAR( SUM("Day-29")) AS "Day-29",
           TO_CHAR( SUM("Day-30")) AS "Day-30",
           TO_CHAR( SUM("Day-31")) AS "Day-31",
           TO_CHAR( SUM(TOTAL)) as TOTAL
FROM
    (
        SELECT
            PV.*,
            NVL("Day-1",0)+ NVL("Day-2",0)+ NVL("Day-3",0)+ NVL("Day-4",0)+ NVL("Day-5",0)+ NVL("Day-6",0)+ NVL("Day-7",0)+ NVL("Day-8",0)+ NVL("Day-9",0)+NVL("Day-10",0)+NVL("Day-11",0)+ NVL("Day-12",0)+ NVL("Day-13",0)+ NVL("Day-14",0)+ NVL("Day-15",0)+ NVL("Day-16",0)+ NVL("Day-17",0)+ NVL("Day-18",0)+ NVL("Day-19",0)+ NVL("Day-20",0)+ NVL("Day-21",0)+ NVL("Day-22",0)+ NVL("Day-23",0)+ NVL("Day-24",0)+ NVL("Day-25",0)+ NVL("Day-26",0)+ NVL("Day-27",0)+ NVL("Day-28",0)+ NVL("Day-29",0)+ NVL("Day-30",0)+ NVL("Day-31",0) AS TOTAL
        FROM
            (
                SELECT
                    NVL(name,'_Grand Total') as name,
                    STARTUPDATE,
                    General_Manager,
                    IsOpen,
                    TO_CHAR(From_Price) From_Price,
                    TO_CHAR(To_Price) To_Price,
                    TO_CHAR(case when "Day-1">10 then "Day-1" else null end) AS "Day-1",
                    TO_CHAR(case when "Day-2">10 then "Day-2" else null end) AS "Day-2",
                    TO_CHAR(case when "Day-3">10 then "Day-3" else null end) AS "Day-3",
                    TO_CHAR(case when "Day-4">10 then "Day-4" else null end) AS "Day-4",
                    TO_CHAR(case when "Day-5">10 then "Day-5" else null end) AS "Day-5",
                    TO_CHAR(case when "Day-6">10 then "Day-6" else null end) AS "Day-6",
                    TO_CHAR(case when "Day-7">10 then "Day-7" else null end) AS "Day-7",
                    TO_CHAR(case when "Day-8">10 then "Day-8" else null end) AS "Day-8",
                    TO_CHAR(case when "Day-9">10 then "Day-9" else null end) AS "Day-9",
                    TO_CHAR(case when "Day-10">10 then "Day-10" else null end) AS "Day-10",
                    TO_CHAR(case when "Day-11">10 then "Day-11" else null end) AS "Day-11",
                    TO_CHAR(case when "Day-12">10 then "Day-12" else null end) AS "Day-12",
                    TO_CHAR(case when "Day-13">10 then "Day-13" else null end) AS "Day-13",
                    TO_CHAR(case when "Day-14">10 then "Day-14" else null end) AS "Day-14",
                    TO_CHAR(case when "Day-15">10 then "Day-15" else null end) AS "Day-15",
                    TO_CHAR(case when "Day-16">10 then "Day-16" else null end) AS "Day-16",
                    TO_CHAR(case when "Day-17">10 then "Day-17" else null end) AS "Day-17",
                    TO_CHAR(case when "Day-18">10 then "Day-18" else null end) AS "Day-18",
                    TO_CHAR(case when "Day-19">10 then "Day-19" else null end) AS "Day-19",
                    TO_CHAR(case when "Day-20">10 then "Day-20" else null end) AS "Day-20",
                    TO_CHAR(case when "Day-21">10 then "Day-21" else null end) AS "Day-21",
                    TO_CHAR(case when "Day-22">10 then "Day-22" else null end) AS "Day-22",
                    TO_CHAR(case when "Day-23">10 then "Day-23" else null end) AS "Day-23",
                    TO_CHAR(case when "Day-24">10 then "Day-24" else null end) AS "Day-24",
                    TO_CHAR(case when "Day-25">10 then "Day-25" else null end) AS "Day-25",
                    TO_CHAR(case when "Day-26">10 then "Day-26" else null end) AS "Day-26",
                    TO_CHAR(case when "Day-27">10 then "Day-27" else null end) AS "Day-27",
                    TO_CHAR(case when "Day-28">10 then "Day-28" else null end) AS "Day-28",
                    TO_CHAR(case when "Day-29">10 then "Day-29" else null end) AS "Day-29",
                    TO_CHAR(case when "Day-30">10 then "Day-30" else null end) AS "Day-30",
                    TO_CHAR(case when "Day-31">10 then "Day-31" else null end) AS "Day-31"
                FROM
                    (
                        SELECT
                            c.name,
                            TO_CHAR(c.STARTUPDATE, 'yyyy-MM-dd')    STARTUPDATE ,
                            a.name                                  General_Manager,
                            p.center||'p'||p.id                     memberID,
                            s.SUBSCRIPTION_PRICE                    From_Price,
                            sp.PRICE                                To_Price,
                            extract(DAY FROM sp.FROM_DATE)       AS DAY_OF,
                            CASE
                                WHEN c.STARTUPDATE>SYSDATE
                                THEN 'Pre-Join'
                                ELSE 'Open'
                            END AS IsOpen,
                            0   AS TOTAL
                        FROM
                            persons p
                        JOIN
                            PUREGYM.SUBSCRIPTIONS s
                        ON
                            s.OWNER_CENTER = p.CENTER
                            AND s.OWNER_ID = p.ID
                            AND s.STATE IN (2,4)
                        JOIN
                            PUREGYM.SUBSCRIPTION_PRICE sp
                        ON
                            sp.SUBSCRIPTION_CENTER = s.CENTER
                            AND sp.SUBSCRIPTION_ID = s.id
                            AND sp.FROM_DATE > SYSDATE
                            AND SP.FROM_DATE< add_months(TRUNC(SYSDATE,'MM'),1)
                            AND sp.CANCELLED = 0
                        JOIN
                            PUREGYM.CENTERS c
                        ON
                            c.id = p.center
                        JOIN
                            AREA_CENTERS AC
                        ON
                            C.ID = AC.CENTER
                        JOIN
                            AREAS A
                        ON
                            A.ID = AC.AREA
                            AND A.PARENT = 61
                        WHERE
                            p.STATUS IN (1,3)
                            AND c.id IN($$scope$$)) pivot (( COUNT(memberID)) FOR DAY_OF IN ( 1 AS "Day-1" ,
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
                                                                                               31 AS "Day-31" )) ) PV
        WHERE
            NVL("Day-1",0)+ NVL("Day-2",0)+ NVL("Day-3",0)+ NVL("Day-4",0)+ NVL("Day-5",0)+ NVL("Day-6",0)+ NVL("Day-7",0)+ NVL("Day-8",0)+ NVL("Day-9",0)+NVL("Day-10",0)+NVL("Day-11",0)+ NVL("Day-12",0)+ NVL("Day-13",0)+ NVL("Day-14",0)+ NVL("Day-15",0)+ NVL("Day-16",0)+ NVL("Day-17",0)+ NVL("Day-18",0)+ NVL("Day-19",0)+ NVL("Day-20",0)+ NVL("Day-21",0)+ NVL("Day-22",0)+ NVL("Day-23",0)+ NVL("Day-24",0)+ NVL("Day-25",0)+ NVL("Day-26",0)+ NVL("Day-27",0)+ NVL("Day-28",0)+ NVL("Day-29",0)+ NVL("Day-30",0)+ NVL("Day-31",0) > 10)
GROUP BY
    rollup( (name,STARTUPDATE,IsOpen,General_Manager,From_Price,To_Price,TOTAL)))