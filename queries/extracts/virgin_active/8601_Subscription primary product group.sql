 select
 pr.center as Center,
 ce.SHORTNAME as Center_Name,
 pr.name as Subcription_Name,
 pr.GLOBALID as Subscription_Global_ID,
 pg.name as ProductGroup
 from
 PRODUCTS pr
 JOIN PRODUCT_GROUP pg
 ON pr.PRIMARY_PRODUCT_GROUP_ID = pg.ID
 JOIN CENTERS ce
 ON pr.CENTER = ce.ID
 where
 pr.PTYPE=10
