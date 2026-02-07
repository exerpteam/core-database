 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             c.id,
             datetolongC(TO_CHAR(cast(:FromDate as date), 'YYYY-MM-dd HH24:MI'), c.id)                     AS FromDate,
             datetolongC(TO_CHAR(cast(:ToDate as date), 'YYYY-MM-dd HH24:MI'), c.id) + (24*60*60*1000)-1 AS ToDate
         FROM
             centers c
         WHERE
             c.id IN (:Scope)
 )
 select distinct
 invl.TEXT,
 --longtodate(pu.USE_TIME) as useddate,
 prg.name,
 invl.center ||'inv'|| invl.id AS INVOICELINE,
 invl.person_center ||'p'|| invl.person_id AS MEMBERID,
 invl.TOTAL_AMOUNT,
 invl.PRODUCT_NORMAL_PRICE,
 c.COUNTRY
 from PRIVILEGE_RECEIVER_GROUPS prg
 cross join params
 JOIN
     PRIVILEGE_GRANTS pg
 on prg.id = pg.GRANTER_ID
 and pg.GRANTER_SERVICE = 'ReceiverGroup'
 join SATS.PRIVILEGE_USAGES pu on pu.source_id = prg.id and pu.source_center is null and pu.SOURCE_SUBID is null
 and pu.grant_id = pg.id
 and pu.target_start_time >= params.FromDate and pu.target_start_time <= params.ToDate
 JOIN
     INVOICE_LINES_MT invl
 ON
     invl.CENTER = pu.TARGET_CENTER
     AND invl.ID = pu.TARGET_ID
     AND invl.SUBID = pu.TARGET_SUBID
 join centers c
 on
 invl.center = c.id
 JOIN
    PRODUCTS pr
 ON
    invl.Productcenter = pr.center
    AND invl.PRODUCTID = pr.ID
 where
prg.name like 'Rewards - PT discount%'
 and invl.center in (:Scope)
