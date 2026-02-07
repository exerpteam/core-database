SELECT

DISTINCT prod.center||'prod'||prod.id AS "Product ID",
prod.center,
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
stype.bindingperiodcount AS "Binding",
stype.periodcount AS "Frequency",
CASE stype.periodunit
	WHEN 0 THEN 'WEEK'
	WHEN 1 THEN 'DAY'
	WHEN 2 THEN 'MONTH'
	END AS "Period Unit",
stype.renew_window,
stype.info_text,
stype.auto_stop_on_binding_end_date AS "AutoStop",
stype.autorenew_binding_count AS "RenewBinding",
stype.autorenew_binding_notice_count "RenewSpan",
prod.coment,
prod.requiredrole,
stype.rec_clipcard_product_clips AS "Clipcard",
stype.adminfeeproduct_id AS "AdminProdId",
prod.external_id AS "External id",
ei.IDENTITY                      AS "Barcode",
prod.product_account_config_id AS "accountConfigId",
pac.name AS "accountConfigName",
prod.PRICE AS "Price",
prod.COST_PRICE AS "Cost price"

FROM 
     PRODUCTS prod 
LEFT JOIN 
	PRODUCT_GROUP pgroup 
ON 
     prod.PRIMARY_PRODUCT_GROUP_ID = pgroup.id 

LEFT JOIN 
	product_account_configurations pac 
ON 
     prod.product_account_config_id = pac.id 

LEFT JOIN
	subscriptiontypes stype
ON stype.center = prod.CENTER
AND stype.ID = prod.id

LEFT JOIN
    ENTITYIDENTIFIERS ei
ON
    ei.REF_CENTER = prod.CENTER
    AND ei.ref_globalid = prod.globalid
    AND ei.entitystatus = 1
	AND ei.ref_type = 4


where
 prod.center  IN (:scope)
AND prod.PTYPE IN (10)
ORDER BY 
     prod.center||'prod'||prod.id