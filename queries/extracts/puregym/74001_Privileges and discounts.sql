 Select distinct
 p.globalid as "GlobalID",
 pg.id  as "Product Group",
 pp.PRICE_MODIFICATION_NAME as "Modification type",
 case
 when pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
 then (pp.PRICE_MODIFICATION_AMOUNT*100)||'%'
 else pp.PRICE_MODIFICATION_AMOUNT||'' end as "Price Modification",
 pp.PRICE_MODIFICATION_ROUNDING as "Rounding"
 from
 PRIVILEGE_SETS ps
 JOIN
    PRODUCT_PRIVILEGES pp
 on
 ps.ID = pp.PRIVILEGE_SET
 left join
 MASTERPRODUCTREGISTER mpr
 on
  pp.REF_GLOBALID = mpr.globalid
 left join
 products p
 on
 p.globalid = mpr.globalid
 and pp.ref_type = 'GLOBAL_PRODUCT'
 left join
 PRODUCT_GROUP pg
 on
 pp.ref_id = pg.id
 and
 pp.ref_type = 'PRODUCT_GROUP'
 where
 ps.id = CAST(:privilegeset_id AS INT)
 and pp.VALID_TO is null
