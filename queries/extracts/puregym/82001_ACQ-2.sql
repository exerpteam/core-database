-- The extract is extracted from Exerp on 2026-02-08
-- Gets data for Privilege Set Discounts
Select distinct
p.globalid as "GlobalId",
pg.id  as "ProductGroup",
pp.PRICE_MODIFICATION_NAME as "DiscountType",
pp.PRICE_MODIFICATION_AMOUNT::float(4) as "Discount",
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
ps.id in ($$privilegeset_id$$) 
and pp.VALID_TO is null