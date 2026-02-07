SELECT
	per.center						AS CenterID,
    cen.SHORTNAME					AS CenterName,
    per.center || 'p' || per.id 	AS PersonID,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') PERSONTYPE, 
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') PERSONSTATUS,
	--per.FIRSTNAME,
	--per.LASTNAME,
	--per.ADDRESS1,
	--per.ADDRESS2,
	--per.ZIPCODE,
	--per.CITY,
    --pea_email.txtvalue 				AS Email,
    --pea_mobile.txtvalue 			AS Mobile,
	prod.NAME						AS ProductName,
	cc.price,
	cc.CLIPS_INITIAL,
	CC.CLIPS_LEFT,
	TO_CHAR(longtodate(cc.VALID_FROM), 'YYYY-MM-DD') SalesDate,
	TO_CHAR(longtodate(cc.VALID_UNTIL), 'YYYY-MM-DD') ValidUntil,
	TRUNC(longtodate(cc.VALID_FROM)) - TRUNC(exerpsysdate()) DAYS_SINCE_LAST_BUY,
	DECODE(cc.FINISHED, 0,'ACTIVE', 1,'FINISHED') Status,
	TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD') todays_date
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

WHERE
	per.CENTER IN (:Scope)
    AND pg.NAME IN ('PT Installment', 'Personal Training')
    AND cc.VALID_FROM BETWEEN :Sales_date_from AND :Sales_date_to
ORDER BY
	per.CENTER,
	cc.VALID_FROM