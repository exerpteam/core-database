-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT 
DISTINCT prod.center||'prod'||prod.id "Product ID",
 CASE prod.blocked
   WHEN 1 THEN 'YES'
   WHEN 0 THEN 'NO'
END AS "Blocked",
prod.GLOBALID "Global id", 
CASE prod.PTYPE
  WHEN 1 THEN 'Goods'
  WHEN 2 THEN 'Service'
  WHEN 4 THEN 'Clipcard'
  WHEN 5 THEN 'Subscription creation'
  WHEN 6 THEN 'Transfer'
  WHEN 7 THEN 'Freeze period'
  WHEN 8 THEN 'Gift card'
  WHEN 9 THEN 'Free gift card'
  WHEN 10 THEN 'Subscription'
  WHEN 12 THEN 'Subscription pro-rata'
  WHEN 13 THEN 'Subscription add-on'
  WHEN 14 THEN 'Access product'
END AS  "Product type",
pgroup.NAME "Product group",
prod.NAME "Product name", 
prod.external_id "External id",
prod.PRICE "Price",
prod.COST_PRICE "Cost price"
FROM 
     PRODUCTS prod 
LEFT JOIN 
	PRODUCT_GROUP pgroup 
ON 
     prod.PRIMARY_PRODUCT_GROUP_ID = pgroup.id 

where
 prod.center  IN (:scope)
ORDER BY 
     prod.center||'prod'||prod.id