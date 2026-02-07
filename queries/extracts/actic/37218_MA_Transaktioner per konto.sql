

SELECT
---------------------------------	
-- Center and sale
	cen.COUNTRY,
	cen.EXTERNAL_ID 										AS Cost,
	cen.ID 													AS CENTERID,
	il.CENTER || 'inv' || il.ID 							AS InvoiceId,
	il.SUBID 												AS Invoiceline,
	TO_CHAR(longToDate(i.TRANS_TIME), 'YYYY-MM-DD HH24:MI') AS Trans_Time,
	TO_CHAR(longToDate(i.ENTRY_TIME), 'YYYY-MM-DD HH24:MI') AS Entry_Time,
	i.CASHREGISTER_CENTER, -- cashregister of center where the sales is typed
---------------------------------	
-- Product
--	prod.PTYPE AS PRODUCT_TYPE,
	CASE  prod.ptype  WHEN 1 THEN 'RETAIL'  WHEN 2 THEN 'SERVICE'  WHEN 4 THEN 'CLIPCARD'  WHEN 5 THEN 'JOINING FEE'  WHEN 8 THEN 'GIFTCARD'  WHEN 10 THEN 'SUBSCRIPTION'  WHEN 14 THEN 'ACCESS' END AS ProductType,
	prod.CENTER || 'prod' || prod.ID 						AS ProductId,
	(il.TEXT)::varchar,
	prod.NAME 												AS PRODUCTNAME,
	cc.CLIP_COUNT 											AS CLIPS_INITIAL,
	il.QUANTITY,
	il.PRODUCT_COST,
	il.PRODUCT_NORMAL_PRICE,
	il.TOTAL_AMOUNT,
	il.TOTAL_AMOUNT / (1 + aiVAT.rate) 						AS TOTAL_AMOUNT_Excl,
	il.TOTAL_AMOUNT * (aiVAT.rate) 							AS VAT_AMOUNT,
	'SALE'													AS SALESTYPE,
	ai.external_id 											AS income_ext_id,
    aiVAT.rate 												AS income_vat,
	prod.GLOBALID,
	pg.NAME 												AS ProductGroup,
	allPG.Group_ID 											AS All_ProductGroups,
---------------------------------	
-- persons
	i.EMPLOYEE_CENTER || 'emp' || i.EMPLOYEE_ID 			AS EmployeeID,
	emp_person.FIRSTNAME || ' ' || emp_person.LASTNAME 		AS Employee,
	CASE
		WHEN i.PAYER_CENTER IS NOT NULL
		THEN i.PAYER_CENTER || 'p' || i.PAYER_ID
		ELSE NULL
	END 													AS Payer,
	CASE
		WHEN per.CENTER IS NOT NULL
		THEN per.CENTER || 'p' || per.ID
		ELSE NULL
	END 													AS PersonID,
	per.Fullname,
	CASE  per.status  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN 'CONTACT'  ELSE NULL END AS PERSONTYPE, -- null for anonymous
    CASE  per.status  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARY INACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN  'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 9 THEN 'CONTACT'  ELSE NULL END  AS PERSONSTATUS -- null for anonymous
	
---------------------------------	
FROM
	INVOICES i -- receipt with possible multiple lines/product
JOIN INVOICELINES il -- all lines/product in a receipt
ON
	il.center = i.center
	AND il.id = i.id
JOIN PRODUCTS prod
ON
	prod.center = il.PRODUCTCENTER
	AND prod.id = il.PRODUCTID
LEFT JOIN PRODUCT_GROUP pg
ON
	prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN
	(
		SELECT 
			pgl.PRODUCT_CENTER,
			pgl.PRODUCT_ID,
		--	LISTAGG(pgl.PRODUCT_GROUP_ID, ' ') WITHIN GROUP (ORDER BY pgl.PRODUCT_GROUP_ID) AS Group_ID,
			string_agg(pg.NAME, ';' ORDER BY pg.NAME) AS Group_ID
		FROM PRODUCT_AND_PRODUCT_GROUP_LINK pgl
		LEFT JOIN PRODUCT_GROUP pg
		ON
			pgl.PRODUCT_GROUP_ID = pg.ID

		GROUP BY
			pgl.PRODUCT_CENTER,
			pgl.PRODUCT_ID
	) allPG
ON
	prod.CENTER = allPG.PRODUCT_CENTER
	AND prod.ID = allPG.PRODUCT_ID

-----------------------------------------------------------------	
LEFT JOIN CLIPCARDTYPES cc
ON
	prod.CENTER = cc.CENTER
	AND prod.ID = cc.ID
LEFT JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
	pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
    -- Income accounts
LEFT JOIN accounts ai
ON
	ai.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
    AND ai.center = prod.CENTER
left join ACCOUNT_VAT_TYPE_GROUP avtg on     avtg.ID = ai.ACCOUNT_VAT_TYPE_GROUP_ID
left join ACCOUNT_VAT_TYPE_LINK actl on actl.ACCOUNT_VAT_TYPE_GROUP_ID =   avtg.ID                                                              
    
LEFT JOIN VAT_TYPES aiVAT
ON
    aiVAT.center = actl.VAT_TYPE_CENTER
    AND aiVAT.id = actl.VAT_TYPE_ID
JOIN CENTERS cen
ON
	i.center = cen.id
LEFT JOIN PERSONS per
ON
	il.PERSON_CENTER = per.center
	AND il.PERSON_ID = per.id
LEFT JOIN EMPLOYEES emp
ON
	i.EMPLOYEE_CENTER = emp.CENTER
	AND i.EMPLOYEE_ID = emp.ID	
LEFT JOIN PERSONS emp_person
ON
	emp.PERSONCENTER = emp_person.CENTER
	AND emp.PERSONID = emp_person.ID
	
WHERE
	i.CENTER IN (:ChosenScope)
--  AND i.TRANS_TIME >= datetolong(TO_CHAR(ROUND(current_timestamp -1), 'YYYY-MM-DD HH24:MI')) -- yesterday at midnight
--	AND i.TRANS_TIME < datetolong(TO_CHAR(ROUND(current_timestamp -1), 'YYYY-MM-DD HH24:MI')) + 86399*1000 -- yesterday at midnight +24 hours in ms

AND i.TRANS_TIME >= :FromDate				--long date
AND i.TRANS_TIME < :ToDate + 3600*1000*24	--long date
	--AND prod.ptype NOT IN (5, 10)
AND ai.external_id IN (:Konto)

/*######################################################*/	
UNION ALL
/*######################################################*/	

SELECT
---------------------------------	
-- Center and sale
	cen.COUNTRY,
	cen.EXTERNAL_ID AS Cost,
	cen.ID AS CENTERID,
	cl.CENTER || 'inv' || cl.ID AS InvoiceId,
	cl.SUBID AS Invoiceline,
	TO_CHAR(longToDate(c.TRANS_TIME), 'YYYY-MM-DD HH24:MI') AS Trans_Time,
	TO_CHAR(longToDate(c.ENTRY_TIME), 'YYYY-MM-DD HH24:MI') AS Entry_Time,
	c.CASHREGISTER_CENTER, -- cashregister of center where the sales is typed
---------------------------------	
-- Product

--	prod.PTYPE AS PRODUCT_TYPE,
	CASE  prod.ptype  WHEN 1 THEN 'RETAIL'  WHEN 2 THEN 'SERVICE'  WHEN 4 THEN 'CLIPCARD'  WHEN 5 THEN 'JOINING FEE'  WHEN 8 THEN 'GIFTCARD'  WHEN 10 THEN 'SUBSCRIPTION'  WHEN 14 THEN 'ACCESS' END AS ProductType,
	prod.CENTER || 'prod' || prod.ID AS ProductId,
	(cl.TEXT)::varchar,
	prod.NAME AS PRODUCTNAME,
	cc.CLIPS_INITIAL,
	cl.QUANTITY,
	cl.PRODUCT_COST,
--	cl.PRODUCT_NORMAL_PRICE, -- don't exists in credit notes
	NULL AS PRODUCT_NORMAL_PRICE,
	cl.TOTAL_AMOUNT * -1,
	(cl.TOTAL_AMOUNT / (1 + aiVAT.rate)) * -1 AS TOTAL_AMOUNT_Excl,
	(cl.TOTAL_AMOUNT * (aiVAT.rate)) * -1 AS VAT_AMOUNT,
	'CREDIT'			AS SALESTYPE,
	ai.external_id 		AS income_ext_id,
	aiVAT.rate 			AS income_vat,
	prod.GLOBALID,
	pg.NAME AS ProductGroup,
	allPG.Group_ID AS All_ProductGroups,
---------------------------------	
-- persons
	c.EMPLOYEE_CENTER || 'emp' || c.EMPLOYEE_ID AS EmployeeID,
	emp_person.FIRSTNAME || ' ' || emp_person.LASTNAME AS Employee,
	CASE
		WHEN c.PAYER_CENTER IS NOT NULL
		THEN c.PAYER_CENTER || 'p' || c.PAYER_ID
		ELSE NULL
	END AS Payer,
	CASE
		WHEN per.CENTER IS NOT NULL
		THEN per.CENTER || 'p' || per.ID
		ELSE NULL
	END AS PersonID,
	per.Fullname,
	CASE  per.status  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN 'CONTACT'  ELSE NULL END AS PERSONTYPE, -- null for anonymous
    CASE  per.status  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARY INACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN  'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 9 THEN 'CONTACT'  ELSE NULL END  AS PERSONSTATUS -- null for anonymous
	
---------------------------------	
FROM
	CREDIT_NOTES c -- receipt with possible multiple lines/product
JOIN CREDIT_NOTE_LINES cl -- all lines/product in a receipt
ON
	cl.center = c.center
	AND cl.id = c.id
JOIN PRODUCTS prod
ON
	prod.center = cl.PRODUCTCENTER
	AND prod.id = cl.PRODUCTID
LEFT JOIN PRODUCT_GROUP pg
ON
	prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN
	(
		SELECT 
			pgl.PRODUCT_CENTER,
			pgl.PRODUCT_ID,
		--	LISTAGG(pgl.PRODUCT_GROUP_ID, ' ') WITHIN GROUP (ORDER BY pgl.PRODUCT_GROUP_ID) AS Group_ID,
			string_agg(pg.NAME, ';' ORDER BY pg.NAME) AS Group_ID
		FROM PRODUCT_AND_PRODUCT_GROUP_LINK pgl
		LEFT JOIN PRODUCT_GROUP pg
		ON
			pgl.PRODUCT_GROUP_ID = pg.ID

		GROUP BY
			pgl.PRODUCT_CENTER,
			pgl.PRODUCT_ID
	) allPG
ON
	prod.CENTER = allPG.PRODUCT_CENTER
	AND prod.ID = allPG.PRODUCT_ID
-----------------------------------------------------------------	
	
LEFT JOIN CLIPCARDS cc
ON
	cl.CENTER = cc.INVOICELINE_CENTER
	AND cl.ID = cc.INVOICELINE_ID
	AND cl.SUBID = cc.INVOICELINE_SUBID
LEFT JOIN PRODUCT_ACCOUNT_CONFIGURATIONS pac
ON
	pac.ID = prod.PRODUCT_ACCOUNT_CONFIG_ID
    -- Income accounts
LEFT JOIN accounts ai
ON
	ai.GLOBALID = pac.SALES_ACCOUNT_GLOBALID
    AND ai.center = prod.CENTER
left join ACCOUNT_VAT_TYPE_GROUP avtg on     avtg.ID = ai.ACCOUNT_VAT_TYPE_GROUP_ID
left join ACCOUNT_VAT_TYPE_LINK actl on actl.ACCOUNT_VAT_TYPE_GROUP_ID =   avtg.ID     
LEFT JOIN VAT_TYPES aiVAT
ON
    aiVAT.center = actl.VAT_TYPE_CENTER
    AND aiVAT.id = actl.VAT_TYPE_ID
JOIN CENTERS cen
ON
	c.center = cen.id
LEFT JOIN PERSONS per
ON
	cl.PERSON_CENTER = per.center
	AND cl.PERSON_ID = per.id
LEFT JOIN EMPLOYEES emp
ON
	c.EMPLOYEE_CENTER = emp.CENTER
	AND c.EMPLOYEE_ID = emp.ID	
LEFT JOIN PERSONS emp_person
ON
	emp.PERSONCENTER = emp_person.CENTER
	AND emp.PERSONID = emp_person.ID

	
WHERE
	c.CENTER IN (:ChosenScope)
--  AND c.TRANS_TIME >= datetolong(TO_CHAR(ROUND(current_timestamp -1), 'YYYY-MM-DD HH24:MI')) -- yesterday at midnight
--	AND c.TRANS_TIME < datetolong(TO_CHAR(ROUND(current_timestamp -1), 'YYYY-MM-DD HH24:MI')) + 86399*1000 -- yesterday at midnight +24 hours in ms
--	AND c.TRANS_TIME BETWEEN (fromDate) AND (toDate + 3600*1000*24-1) --long date

AND c.TRANS_TIME >= :FromDate				--long date
 AND c.TRANS_TIME < :ToDate + 3600*1000*24	--long date
	--AND prod.ptype NOT IN (5, 10)
AND ai.external_id IN (:Konto)
ORDER BY
	TRANS_TIME
