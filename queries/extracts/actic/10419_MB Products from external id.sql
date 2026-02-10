-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	cen.EXTERNAL_ID 	AS Cost,
	p.center 			AS CenterId,
	cen.shortname 		AS CenterName,
	DECODE (p.ptype, 1,'RETAIL', 2,'SERVICE', 4,'CLIPCARD', 5,'JOINING FEE', 8,'GIFTCARD', 10,'SUBSCRIPTION') AS ProductType,
	p.name 				AS ProductName,
    ai.external_id 		AS income_ext_id,
    aiVAT.rate 			AS income_vat,
	pac.name			AS AccountConfiguration,
	ai.name				AS IncomeAccount,
--  ae.external_id 		AS expence_ext_id,
--  aeVAT.rate 			AS expence_vat,
--  ar.external_id 		AS refund_ext_id,
--  arVAT.rate 			AS refund_vat,
	pac.SALES_ACCOUNT_GLOBALID AS AccountGlobalid,
    p.GLOBALID 			AS GlobalId
FROM
    products p
JOIN CENTERS cen
ON
	cen.id = p.center
LEFT JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
	pac.ID = p.PRODUCT_ACCOUNT_CONFIG_ID
    -- Income accounts
LEFT JOIN accounts ai
ON
	ai.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
    AND ai.center = p.CENTER
	
	left join ACCOUNT_VAT_TYPE_GROUP avtg 
	on     avtg.ID = ai.ACCOUNT_VAT_TYPE_GROUP_ID
	
	left join ACCOUNT_VAT_TYPE_LINK actl 
on actl.ACCOUNT_VAT_TYPE_GROUP_ID =   avtg.ID  

	
	LEFT JOIN VAT_TYPES aiVAT
ON
    aiVAT.center = actl.VAT_TYPE_CENTER
    AND aiVAT.id = actl.VAT_TYPE_ID


WHERE    
ai.EXTERNAL_ID IN (:Account)
    AND p.CENTER in ( :ChosenScope )
     AND p.BLOCKED = 0
ORDER BY
    p.center,
    p.ptype,
	p.name