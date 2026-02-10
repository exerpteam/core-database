-- The extract is extracted from Exerp on 2026-02-08
-- Created in 2014 by DB
 SELECT
     e1.*,
     e1."Today's Joiners 4pm"-e1."Today's Leavers 4pm" AS "Today's Net Gain 4pm"
 FROM
     (
         SELECT
             -- DECODE(c.id,NULL,'total',c.id)as "Center ID"
             CASE   WHEN c.NAME IS NULL  THEN ' Grand Total' ELSE c.name END AS "Center Name",
             CASE
                 WHEN c.STARTUPDATE>CURRENT_TIMESTAMP
                 THEN 'Pre-Join'
                 WHEN C.STARTUPDATE IS NULL
                 THEN NULL
                 ELSE 'Open'
             END                                           AS "Center Status",
             a.name                                    AS "Region",
             SUM( CASE kd.field WHEN 615 THEN kd.value ELSE NULL END)      AS "Today's Joiners 4pm",
             SUM( CASE kd.field WHEN 3001 THEN kd.value ELSE NULL END ) AS "Today's Leavers 4pm"
             -- SUM(DECODE(kd.field,604,kd.value,NULL))   AS "Today's Net Gain 4pm"
         FROM
             KPI_DATA kd
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
             AND A.PARENT = 61
         WHERE
             kd.field IN (604,615,3001,406)
             AND kd.for_date = TRUNC(CURRENT_TIMESTAMP)
             AND c.ID != 100
 --        HAVING
 --            SUM( DECODE(kd.field,406,kd.value,NULL)) >0
         GROUP BY
             grouping sets ( (c.name,A.NAME,C.STARTUPDATE), () )
         ORDER BY
             c.NAME) e1
