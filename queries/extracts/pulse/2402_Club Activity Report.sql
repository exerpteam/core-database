 SELECT
     dataset.*,
     longtodate(:FromDate) fromDate,
     longtodate(:ToDate) toDate
 from (
 SELECT
     center,
     sales_club centerName,
     pname "text",
     '1. Casual access' reportgroup,
     CASE
         WHEN pgId = 2602
         THEN 'Casual Swim'
         WHEN pgId = 2603
         THEN 'Casual Gym'
         WHEN pgId = 2604
         THEN 'Casual Classes'
         WHEN pgId = 2605
         THEN 'Casual Bookings'
         WHEN pgId = 2606
         THEN 'Casual Access'
     END subgroup,
     CASE
         WHEN pgId IN (2602,2603,2606)
         THEN SUM(QUANTITY)
         ELSE 0
     END attends,
     CASE
         WHEN pgId = 2604
         THEN SUM(QUANTITY)
         ELSE 0
     END classes,
     CASE
         WHEN pgId = 2605
         THEN SUM(QUANTITY)
         ELSE 0
     END resources,
     ROUND(CAST (SUM(QUANTITY) / (extract(DAY FROM (longtodate(:ToDate) - longtodate(:FromDate))) + 1) AS DECIMAL), 2) average
 FROM
     (
         SELECT
             i.center,
             club.SHORTNAME sales_club,
             TO_CHAR(longtodate(i.TRANS_TIME), 'YYYY-MM-DD') dato,
             prod.NAME pname,
             il.QUANTITY,
             pg.NAME pgName,
             pg.ID pgId
         FROM
             INVOICES i
         JOIN invoice_lines_mt il
         ON
             il.center = i.center
             AND il.id = i.id
         JOIN PRODUCTS prod
         ON
             prod.center = il.PRODUCTCENTER
             AND prod.id = il.PRODUCTID
         JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
         ON
             ppgl.PRODUCT_CENTER = prod.CENTER
             AND ppgl.PRODUCT_ID = prod.ID
         JOIN PRODUCT_GROUP pg
         ON
             ppgl.PRODUCT_GROUP_ID = pg.ID
         JOIN CENTERS club
         ON
             i.center = club.id
         WHERE
             i.TRANS_TIME >= datetolong('2012-02-01 00:00')
             AND i.TRANS_TIME < datetolong('2012-02-29 00:00') + 60*60*1000*24
             AND i.CENTER IN (:Scope) -- change from '200'
             AND pg.ID IN (2602,2603,2604,2605,2606)
         UNION ALL
         SELECT
             c.center sales_center,
             club.SHORTNAME sales_club,
             TO_CHAR(longtodate(c.TRANS_TIME), 'YYYY-MM-DD'),
             prod.NAME pname,
             -cl.QUANTITY,
             pg.NAME pgName,
             pg.ID pgId
         FROM
             CREDIT_NOTES c
         JOIN CREDIT_NOTE_LINES_MT cl
         ON
             cl.center = c.center
             AND cl.id = c.id
         JOIN PRODUCTS prod
         ON
             prod.center = cl.PRODUCTCENTER
             AND prod.id = cl.PRODUCTID
         JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
         ON
             ppgl.PRODUCT_CENTER = prod.CENTER
             AND ppgl.PRODUCT_ID = prod.ID
         JOIN PRODUCT_GROUP pg
         ON
             ppgl.PRODUCT_GROUP_ID = pg.ID
         JOIN CENTERS club
         ON
             c.center = club.id
         WHERE
             c.TRANS_TIME >= datetolong('2012-02-01 00:00')
             AND c.TRANS_TIME < datetolong('2012-02-29 00:00') + 60*60*1000*24
             AND c.CENTER IN (:Scope)
             AND pg.ID IN (2602,2603,2604,2605,2606)
     ) t1
 GROUP BY
     center,
     sales_club,
     pname,
     pgname,
     pgId
 UNION ALL
 SELECT
     center.id AS CENTER ,
     center.SHORTNAME AS CLUB ,
     br.NAME AS TEXT ,
     '2. Member Access' AS REPORTGROUP ,
     'Member Attends' AS SUBGROUP ,
     COUNT(DISTINCT att.person_id || 'p' || att.person_center || ':' || longtodateC(att.start_time, att.center) ) AS ATTENDS,
     0 AS CLASSES,
     0 AS RESOURCES,
     ROUND(CAST ( COUNT(DISTINCT att.person_id || 'p' || att.person_center || ':' || TO_CHAR(longtodate(att.START_TIME),
     'YYYY-MM-DD' ) ) / (extract(DAY FROM (longtodate(:ToDate) - longtodate(:FromDate))) + 1) AS DECIMAL), 2) average
 FROM
     ATTENDS att
 JOIN BOOKING_RESOURCES br
 ON
     br.center = att.BOOKING_RESOURCE_CENTER
     AND br.id = att.BOOKING_RESOURCE_ID
 JOIN CENTERS center
 ON
     center.id = att.center
 JOIN
 persons p
 ON
 p.center = att.person_center
 AND p.id = att.person_id
 WHERE
     att.START_TIME >= :FromDate
     AND att.START_TIME < (:ToDate + 86400 * 1000)
     AND att.STATE = 'ACTIVE'
     AND att.CENTER = :Scope
     AND p.persontype != 2
 GROUP BY
     center.id,
     center.SHORTNAME,
     br.NAME
 UNION ALL
 SELECT
     center.id AS CENTER ,
     center.SHORTNAME AS CLUB ,
     bk.NAME AS TEXT,
     '2. Member Access' AS REPORTGROUP ,
     CASE act.ACTIVITY_TYPE  WHEN 2 THEN  'Member Classes'  WHEN 3 THEN  'Member Resources' END AS SUBGROUP ,
     0 AS ATTENDS,
     SUM(
         CASE
             WHEN act.ACTIVITY_TYPE IN (2)
             THEN 1
             ELSE 0
         END) AS CLASSES ,
     SUM(
         CASE
             WHEN act.ACTIVITY_TYPE IN (3)
             THEN 1
             ELSE 0
         END) AS RESOURCES,
     ROUND(CAST( COUNT(*) / (extract(DAY FROM (longtodate(:ToDate) - longtodate(:FromDate))) + 1) AS DECIMAL), 2) average
 FROM
     PARTICIPATIONS part
 JOIN BOOKINGS bk
 ON
     part.BOOKING_CENTER = bk.center
     AND part.BOOKING_ID = bk.id
 JOIN CENTERS center
 ON
     center.id = bk.center
 JOIN ACTIVITY act
 ON
     bk.ACTIVITY = act.ID
 WHERE
     bk.center = :Scope
     AND part.STATE = 'PARTICIPATION'
     AND bk.state = 'ACTIVE'
     AND bk.STARTTIME >= :FromDate
     AND bk.STARTTIME < (:ToDate + 86400 * 1000)
     AND act.ACTIVITY_TYPE IN (2,3)
 GROUP BY
     center.id,
     center.SHORTNAME,
     act.ACTIVITY_TYPE,
     bk.name
 ) dataset
 ORDER BY 4,5,3
