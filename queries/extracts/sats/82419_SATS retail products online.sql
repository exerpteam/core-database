 SELECT
     prod.name "Product name",
     prod.globalid "Global ID",
     cen.Country "Scope",--prod.center Center,
     prod.price  "Price",
     Pg.name "Product group" ,
     prod.name "Product Name"
     --prod.id "Product ID" ,
 FROM
     PRODUCTs prod
 JOIN
     PRODUCT_AND_PRODUCT_GROUP_LINK plink
 ON
     plink.PRODUCT_CENTER = prod.CENTER
 AND plink.PRODUCT_ID = prod.ID
 JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = plink.PRODUCT_GROUP_ID
 JOIN
     centers cen
 ON
     cen.id = prod.center
 WHERE
     pg.id IN (56402,49402,52802) --Product groups -- 4.SATS Clothing ,4.SATS Nutrition ,4.SATS
     -- Shake it
 AND prod.blocked=0
 AND prod.ptype IN (1) -- Goods
