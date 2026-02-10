-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH PRG AS (
 select * from (
        SELECT
            prg.id,
            cast(unnest(xpath('/configuration/section[@id = "ExtendedAttribute"]/value/text/text()',xmlparse(document
            convert_from(prg.PLUGIN_CONFIG, 'UTF-8')))) as text) AS txtVal,
            prg.name
        FROM
            PRIVILEGE_RECEIVER_GROUPS prg
 ) t
 where txtVal like 'UNBROKENMEMBERSHIPGROUPALL%'
 ),
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
  pu.PERSON_CENTER || 'p' || pu.PERSON_ID as personid,
    invl.TEXT,
    longtodate(pu.USE_TIME) as useddate,
     prg.name,
   invl.PRODUCT_NORMAL_PRICE LIST_PRICE_AT_INVOICING,
  invl.TOTAL_AMOUNT PAID_PRICE_AFTER_DISCOUNT,
  prod.PRICE CURRENT_MONTHLY_PRICE,
 INV.EMPLOYEE_CENTER ||'emp'|| INV.EMPLOYEE_ID "Sales employee"
 from PRG
 JOIN
     PRIVILEGE_GRANTS pg
 on prg.id = pg.GRANTER_ID
 cross join params
 Join
     PRIVILEGE_USAGES pu
 ON
     pg.ID = pu.GRANT_ID
     AND pg.GRANTER_SERVICE = 'ReceiverGroup'
 and pu.target_start_time >= params.FromDate and pu.target_start_time <= params.ToDate
 join persons p
 on
 pu.PERSON_CENTER  = p.center
 and pu.PERSON_id = p.id
 JOIN
     INVOICE_LINES_MT invl
 ON
     invl.CENTER = pu.TARGET_CENTER
     AND invl.ID = pu.TARGET_ID
     AND invl.SUBID = pu.TARGET_SUBID
     AND pu.TARGET_SERVICE = 'InvoiceLine'
 join invoices inv on inv.id= invl.id and inv.center=invl.center
 JOIN
     PRODUCTS prod
 ON
     prod.CENTER = invl.PRODUCTCENTER
     AND prod.ID = invl.PRODUCTID
 and ptype in (2,4)
 where
 p.center in (:Scope)
 and
 prg.name like 'Rewards - PT discount%'
 and pu.USE_TIME >= params.FromDate
 and pu.USE_TIME <= params.ToDate
