/**
* Creator: Mikael Ahlberg
* ServiceTicket: N/A created due to financeauditors request
* Purpose: List products and related accountinformation.
*/
SELECT
	cen.EXTERNAL_ID 	AS Cost,
	p.center 			AS CenterId,
	cen.shortname 		AS CenterName,
	DECODE (p.ptype, 1,'RETAIL', 2,'SERVICE', 4,'CLIPCARD', 5,'JOINING FEE', 8,'GIFTCARD', 10,'SUBSCRIPTION', 13,'Add-on') AS ProductType,
	p.name 				AS ProductName,
	allPG.Group_ID AS All_ProductGroups,
    ai.external_id 		AS income_ext_id,
    aiVAT.rate 			AS income_vat,
	pac.name			AS AccountConfiguration,
	ai.name				AS IncomeAccount,
	pac.SALES_ACCOUNT_GLOBALID AS AccountGlobalid,
    p.GLOBALID 			AS GlobalId,
	p.BLOCKED
FROM
    products p


LEFT JOIN PRODUCT_GROUP pg
ON
	p.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN
	(
		SELECT 
			pgl.PRODUCT_CENTER,
			pgl.PRODUCT_ID,
			LISTAGG(pg.NAME, ';') WITHIN GROUP (ORDER BY pg.NAME) AS Group_ID
		FROM PRODUCT_AND_PRODUCT_GROUP_LINK pgl
		LEFT JOIN PRODUCT_GROUP pg
		ON
			pgl.PRODUCT_GROUP_ID = pg.ID

		GROUP BY
			pgl.PRODUCT_CENTER,
			pgl.PRODUCT_ID
	) allPG
ON
	p.CENTER = allPG.PRODUCT_CENTER
	AND p.ID = allPG.PRODUCT_ID


JOIN CENTERS cen
ON
	cen.id = p.center
LEFT JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
	pac.ID = p.PRODUCT_ACCOUNT_CONFIG_ID
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
     p.CENTER in ( :ChosenScope )
ORDER BY
    p.center,
    p.ptype,
	p.name