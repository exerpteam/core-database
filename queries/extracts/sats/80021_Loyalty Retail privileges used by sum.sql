 SELECT
     t1.numberofsales,
     t1.TEXT,
     t1.privname AS name,
     t1.TOTAL_AMOUNT,
     t1.PRODUCT_NORMAL_PRICE,
     t1.brandname  AS brandname,
     t1.brand1name AS brandname2,
     t1.COUNTRY
 FROM
     (
         WITH
             params AS
             (
                 SELECT
                     /*+ materialize */
                     c.id,
                     datetolongC(TO_CHAR(:FromDate, 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
                     datetolongC(TO_CHAR(:ToDate, 'YYYY-MM-dd HH24:MI'), c.id) + (24*60*60*1000)-1
                     AS ToDate
                 FROM
                     centers c
                 WHERE
                     c.id IN (:Scope)
             )
         SELECT
             count(invl.TEXT) as numberofsales,
             invl.text,
             prg.name                       AS privname,
             SUM(invl.TOTAL_AMOUNT)         AS TOTAL_AMOUNT,
             SUM(invl.PRODUCT_NORMAL_PRICE) AS PRODUCT_NORMAL_PRICE,
             brand.name                     AS brandname,
             brand1.name                    AS brand1name,
             c.COUNTRY
         FROM
             PRIVILEGE_RECEIVER_GROUPS prg
         JOIN
             PRIVILEGE_GRANTS pg
         ON
             prg.id = pg.GRANTER_ID
         AND pg.GRANTER_SERVICE = 'ReceiverGroup'
         JOIN
             PRIVILEGE_USAGES pu
         ON
             pu.source_id = prg.id
         AND pu.source_center IS NULL
         AND pu.SOURCE_SUBID IS NULL
         AND pu.grant_id = pg.id
         JOIN
             INVOICE_LINES_MT invl
         ON
             invl.CENTER = pu.TARGET_CENTER
         AND invl.ID = pu.TARGET_ID
         AND invl.SUBID = pu.TARGET_SUBID
         JOIN
             centers c
         ON
             invl.center = c.id
         JOIN
             params
         ON
             params.id = c.id
         JOIN
             PRODUCTS pr
         ON
             invl.Productcenter = pr.center
         AND invl.PRODUCTID = pr.ID
         LEFT JOIN
             (
                 SELECT
                     pr.center,
                     pr.id,
                     pg2.name AS name
                 FROM
                     products pr
                 JOIN
                     PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                 ON
                     ppg.PRODUCT_CENTER = pr.center
                 AND ppg.PRODUCT_ID = pr.id
                 JOIN
                     product_group pg2
                 ON
                     ppg.PRODUCT_GROUP_ID = pg2.id
                 WHERE
                     pg2.name LIKE '4.%%') brand
         ON
             brand.center = pr.center
         AND brand.id = pr.id
         LEFT JOIN
             (
                 SELECT
                     pr.center,
                     pr.id,
                     pg2.name AS name
                 FROM
                     products pr
                 JOIN
                     PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                 ON
                     ppg.PRODUCT_CENTER = pr.center
                 AND ppg.PRODUCT_ID = pr.id
                 JOIN
                     product_group pg2
                 ON
                     ppg.PRODUCT_GROUP_ID = pg2.id
                 WHERE
                     pg2.name LIKE '1.%%') brand1
         ON
             brand1.center = pr.center
         AND brand1.id = pr.id
         WHERE
             prg.name LIKE 'Rewards - Retail discount%'
         AND pu.target_start_time >= params.FromDate
         AND pu.target_start_time <= params.ToDate
         GROUP BY
             invl.TEXT,
             prg.name,
             c.COUNTRY,
             brand.name,
             brand1.name )t1
