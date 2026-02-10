-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	per.center						AS CenterID,
    cen.SHORTNAME					AS CenterName,
    per.center || 'p' || per.id 	AS PersonID,
    CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END PERSONTYPE, 
    CASE  per.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN' END PERSONSTATUS,
	per.FIRSTNAME,
	per.LASTNAME,
	per.ADDRESS1,
	per.ADDRESS2,
	per.ZIPCODE,
	per.CITY,
    pea_email.txtvalue 				AS Email,
    pea_mobile.txtvalue 			AS Mobile,
	prod.NAME						AS ProductName,
	cc.CLIPS_INITIAL,
	CC.CLIPS_LEFT,
	TO_CHAR(longtodate(cc.VALID_FROM), 'YYYY-MM-DD') SalesDate,
	TO_CHAR(longtodate(cc.VALID_UNTIL), 'YYYY-MM-DD') ValidUntil,
	TRUNC(longtodate(cc.VALID_FROM)) - TRUNC(current_timestamp) DAYS_SINCE_LAST_BUY,
	CASE cc.FINISHED  WHEN 0 THEN 'ACTIVE'  WHEN 1 THEN 'FINISHED' END Status,
	TO_CHAR(TRUNC(current_timestamp), 'YYYY-MM-DD') todays_date,
	inv.EMPLOYEE_CENTER||'emp'||inv.EMPLOYEE_ID AS SalesPerson

FROM
	PERSONS per
JOIN CLIPCARDS cc
ON
	cc.OWNER_CENTER = per.CENTER
	AND cc.OWNER_ID = per.ID
LEFT JOIN PRODUCTS prod
ON
    prod.CENTER = cc.CENTER
    AND prod.ID = cc.ID
--
JOIN PRODUCT_AND_PRODUCT_GROUP_LINK plink
ON
    plink.PRODUCT_CENTER = prod.CENTER
    AND plink.PRODUCT_ID = prod.ID
JOIN PRODUCT_GROUP pg
ON
    pg.ID = plink.PRODUCT_GROUP_ID
--
JOIN centers cen
ON
    cen.ID = per.CENTER
LEFT JOIN PERSON_EXT_ATTRS pea_email 
ON 
	pea_email.PERSONCENTER = per.center 
	AND pea_email.PERSONID = per.id 
	AND pea_email.NAME = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS pea_mobile 
ON
	pea_mobile.PERSONCENTER = per.center 
	AND pea_mobile.PERSONID = per.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN INVOICELINES il
ON
	il.CENTER = cc.INVOICELINE_CENTER
	AND il.ID =  cc.INVOICELINE_ID
	AND il.SUBID = cc.INVOICELINE_SUBID
LEFT JOIN INVOICES inv
ON 
	il.CENTER = inv.CENTER
	AND il.ID = inv.ID

WHERE
	per.CENTER IN (:Scope)
--    AND pg.NAME = 'Personal Training'
    AND cc.VALID_FROM BETWEEN :Sales_date_from AND :Sales_date_to
ORDER BY
	per.CENTER,
	cc.VALID_FROM
