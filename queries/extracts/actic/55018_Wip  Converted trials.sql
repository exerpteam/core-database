/**
* Creator: Henrik Håkanson
* Purpose: Lookup members that initially bought a trial period and then became an active member.
* Limit to CrossFit memberships.
*
*/

SELECT
---------------------------------	
-- Center and sale
	cen.NAME AS CENTERNAME,
	TO_CHAR(longToDate(i.TRANS_TIME), 'YYYY-MM-DD HH24:MI') AS ClipcardSaleDate,
	TO_CHAR(longToDate(s.CREATION_TIME), 'YYYY-MM-DD HH24:MI') AS SUBSCRIPTION_SALE,
	s.START_DATE AS SUBSCRIPTION_START,
	prod.NAME AS PRODUCTNAME,
	CASE
		WHEN per.CENTER IS NOT NULL
		THEN per.CENTER || 'p' || per.ID
		ELSE NULL
	END AS PersonID,
    CASE  per.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARY INACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN  'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 9 THEN 'CONTACT'  ELSE NULL END  AS PERSONSTATUS
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
	
LEFT JOIN CLIPCARDTYPES cc
ON
	prod.CENTER = cc.CENTER
	AND prod.ID = cc.ID
JOIN CENTERS cen
ON
	i.center = cen.id
LEFT JOIN PERSONS per
ON
	il.PERSON_CENTER = per.center
	AND il.PERSON_ID = per.id
FULL OUTER JOIN SUBSCRIPTIONS s
ON
	s.OWNER_CENTER = per.CENTER
	AND s.OWNER_ID = per.ID
	AND 
		(s.STATE = 2 OR s.SUB_STATE = 2)
	AND s.CREATION_TIME > i.TRANS_TIME


WHERE
	i.CENTER IN (:Scope)
	AND i.TRANS_TIME BETWEEN (:fromDate) AND (:toDate + 3600*1000*24-1) --long date
	AND prod.GLOBALID = 'TRIAL_TRAINING_2'	
