-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     /*core2.ROW_NBR,*/
     longToDateC(core2.THIS,core2.center) last_invoiced,
     longToDateC(core2.PREV,core2.center) previous_invoiced,
     /*longToDateC(core2.THIS,core2.center) - longToDateC(core2.PREV,core2.center) diff,*/
     /*core2."ROW",*/
     core2.INV_ID,
     core2.PID,
     /*core2.INV_TRANS_TIME,*/
     core2.PRIMARY_PRODUCT_GROUP,
     core2.PRODUCT_NAME,
     core2.CLIP_PROD_TYPE
 FROM
     (
         SELECT
             ROW_NUMBER( ) OVER (PARTITION BY core.pid ORDER BY core.INV_TRANS_TIME DESC) ROW_NBR,
             LAG(core.INV_TRANS_TIME, 1) OVER (PARTITION BY core.pid ORDER BY core.INV_TRANS_TIME ASC) PREV,
             core.INV_TRANS_TIME THIS,
             CASE
                 WHEN ROW_NUMBER( ) OVER (PARTITION BY core.pid ORDER BY core.INV_TRANS_TIME DESC) = 1
                 THEN 'LAST ROW'
                 ELSE 'PREVIOUS ROWS'
             END AS "ROW" ,
             core.*
         FROM
             (
                 SELECT DISTINCT
                                         inv.center,
                     inv.CENTER || 'inv' || inv.id inv_id,
                     inv.PAYER_CENTER || 'p' || inv.PAYER_ID pid,
                     inv.TRANS_TIME INV_TRANS_TIME,
                     pgr.NAME PRIMARY_PRODUCT_GROUP,
                     prod.NAME PRODUCT_NAME,
                     CASE
                         WHEN prod.PTYPE = 13
                         THEN 'Addon'
                         WHEN prod.PTYPE = 4
                         THEN 'Clip card'
                         ELSE 'Unknown'
                     END AS CLIP_PROD_TYPE
                 FROM
                     INVOICELINES invl
                 JOIN INVOICES inv
                 ON
                     inv.CENTER = invl.CENTER
                     AND inv.ID = invl.ID
                 JOIN PRODUCTS prod
                 ON
                     prod.CENTER = invl.PRODUCTCENTER
                     AND prod.ID = invl.PRODUCTID
                 JOIN PRODUCT_GROUP pgr
                 ON
                     pgr.ID = prod.PRIMARY_PRODUCT_GROUP_ID
                 LEFT JOIN MASTERPRODUCTREGISTER mpr
                 ON
                     mpr.GLOBALID = prod.GLOBALID
                 LEFT JOIN PRIVILEGE_GRANTS pg
                 ON
                     pg.GRANTER_ID = mpr.ID
                     AND pg.GRANTER_SERVICE = 'Addon'
                     AND pg.VALID_TO IS NULL
                 LEFT JOIN PRIVILEGE_SETS ps
                 ON
                     ps.id = pg.PRIVILEGE_SET
                 WHERE
                     pgr.name IN ('PT Clipcards','PT DD Master','Personal Training')
                     AND prod.PTYPE IN( 13,4)
                     AND
                     (
                         prod.PTYPE = 4
                         OR ps.FREQUENCY_RESTRICTION_COUNT IS NOT NULL
                     )
             )
             core
         ORDER BY
             pid,
             INV_TRANS_TIME
     )
     core2
 WHERE
     core2.ROW_NBR = 1
     AND months_between( longToDateC(core2.THIS,core2.center)::date , longToDateC(core2.PREV,core2.center)::date )>6
