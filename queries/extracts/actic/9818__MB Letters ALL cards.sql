-- The extract is extracted from Exerp on 2026-02-08
-- * Can be replaced by 16639 - ended cash subscriptions
/* ALL centers with ALL cards */
/**
* Creator: Martin Blomgren
* Purpose: Select all CASH memberships with the endDate within given period. Show salesprice, therefor join on products. 
* Exclude products like BAD, LIFESTYLE, JUNIOR, BARN
* 
*/

SELECT
	cen.ID AS CenterID,
    cen.NAME CLUB,
    per.center || 'p' || per.id personid,
    per.ssn,
--	per.birthdate,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') PERSONTYPE, 
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') PERSONSTATUS,
    DECODE (sub.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') subscription_STATE,
    DECODE (sub.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED','UNKNOWN')  SUBSCRIPTION_SUB_STATE,
    per.FIRSTNAME,
    per.LASTNAME,
    per.ADDRESS1,
    per.ADDRESS2,
    per.ZIPCODE,
    per.CITY,
--  cen.NAME CLUB,
	TO_CHAR(sub.END_DATE, 'YYYY-MM-DD') end_DATE,
    TO_CHAR(sub.END_DATE + 1, 'YYYY-MM-DD') new_DATE,
--  prod.PRICE currentProdPrice,
--  sub.SUBSCRIPTION_PRICE currentMemberPrice,

	/* Local cards */
	CASE
		WHEN (per.PERSONTYPE = 7 AND p1.PRICE > 0) -- If Senior
		THEN trunc(p1.PRICE * 0.70, -1) + 9
		
		WHEN p1.PRICE = 0
		THEN NULL
		
		ELSE p1.PRICE
	END EFT_LOCAL_PRICE,
	
	CASE
		WHEN p1.PRICE > 0
		THEN p1.NAME 
		
		ELSE NULL
	END EFT_LOCAL_NAME,
	
	CASE
		WHEN (per.PERSONTYPE = 7 AND p2.PRICE > 0) -- If senior
		THEN trunc(p2.PRICE * 0.70, -2) + 95

		WHEN p2.PRICE = 0
		THEN NULL
				
		ELSE p2.PRICE
	END CASH_LOCAL_PRICE,
	
	CASE
		WHEN p2.PRICE > 0
		THEN p2.NAME 
		
		ELSE NULL 
	END CASH_LOCAL_NAME,
	
	/* Local MAX cards */
	CASE
		WHEN (per.PERSONTYPE = 7 AND p3.PRICE > 0) -- If senior
		THEN trunc(p3.PRICE * 0.70, -1) + 9
		
		WHEN p3.PRICE = 0
		THEN NULL
		
		ELSE p3.PRICE
	END EFT_LOCAL_AREA_PRICE,
	
	CASE
		WHEN p3.PRICE > 0
		THEN p3.NAME 
		
		ELSE NULL
	END EFT_lOCAL_AREA_NAME,
			
	CASE
		WHEN (per.PERSONTYPE = 7 AND p4.PRICE > 0) -- If Senior
		THEN trunc(p4.PRICE * 0.70, -2) + 95

		WHEN p4.PRICE = 0
		THEN NULL
				
		ELSE p4.PRICE
	END CASH_LOCAL_AREA_PRICE,
	
	CASE
		WHEN p4.PRICE > 0
		THEN p4.NAME 
		
		ELSE NULL
	END CASH_LOCAL_AREA_NAME,
	
	/* MAX cards */
	CASE
		WHEN (per.PERSONTYPE = 7 AND p5.PRICE > 0) -- If Senior
		THEN trunc(p5.PRICE * 0.70, -1) + 9
		
		WHEN p5.PRICE = 0
		THEN NULL
		
		ELSE p5.PRICE
	END EFT_AREA_PRICE,
	
	CASE
		WHEN p5.PRICE > 0
		THEN p5.NAME
		
		ELSE NULL
	END EFT_AREA_NAME,
	
	CASE
		WHEN (per.PERSONTYPE = 7 AND p6.PRICE > 0) -- If Senior
		THEN trunc(p6.PRICE * 0.70, -2) + 95
		
		WHEN p6.PRICE = 0
		THEN NULL
		
		ELSE p6.PRICE
	END CASH_AREA_PRICE,
	
	CASE
		WHEN p6.PRICE > 0
		THEN p6.NAME 
		
		ELSE NULL
	END CASH_AREA_NAME,
	

    DECODE(subType.ST_TYPE, 0, 'KONTANT', 1, 'AUTOGIRO') currenttype,
	pem.txtvalue AS email,
	pea_mobile.txtvalue AS Mobile,
	prod.NAME currentSubscription

FROM
    SUBSCRIPTIONS sub
JOIN SUBSCRIPTIONTYPES subType
ON
    subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
JOIN PRODUCTS prod
ON
    subType.CENTER = prod.CENTER
    AND subType.ID = prod.ID
JOIN persons per
ON
    sub.OWNER_CENTER = per.CENTER
    AND sub.OWNER_ID = per.ID
JOIN centers cen
ON
    cen.ID = per.CENTER
left join person_ext_attrs pem 
on 
	pem.personcenter = per.center 
	and pem.personid = per.id 
	and pem.name = '_eClub_Email'
left join PERSON_EXT_ATTRS pea_mobile 
on 
	pea_mobile.PERSONCENTER = per.center 
	and pea_mobile.PERSONID = per.id 
	and pea_mobile.NAME = '_eClub_PhoneSMS'

/* Links require privilege with subscription */
LEFT JOIN
	(
		SELECT
			prod.CENTER,
			prod.GLOBALID,
			join_prod.needs_privilege,
			prod.blocked,
			prod.price,
			prod.name			
		FROM
			PRODUCTS prod
		LEFT JOIN SUBSCRIPTIONTYPES join_st
		ON
			prod.CENTER = join_st.CENTER
			AND prod.ID = join_st.ID
		LEFT JOIN PRODUCTS join_prod
		ON
			join_prod.CENTER = join_st.CENTER
			AND join_prod.id = join_st.PRODUCTNEW_ID
	)
	p1
ON
	per.CENTER = p1.center
	AND p1.blocked = 0
	AND p1.needs_privilege = 0
	AND p1.GLOBALID = 'EFT_12_M_RECURRING'
LEFT JOIN
	(
		SELECT
			prod.CENTER,
			prod.GLOBALID,
			join_prod.needs_privilege,
			prod.blocked,
			prod.price,
			prod.name			
		FROM
			PRODUCTS prod
		LEFT JOIN SUBSCRIPTIONTYPES join_st
		ON
			prod.CENTER = join_st.CENTER
			AND prod.ID = join_st.ID
		LEFT JOIN PRODUCTS join_prod
		ON
			join_prod.CENTER = join_st.CENTER
			AND join_prod.id = join_st.PRODUCTNEW_ID
	)
	p2
ON
	per.CENTER = p2.center
	AND p2.blocked = 0
	AND p2.needs_privilege = 0
	AND p2.GLOBALID = 'CASH_12_M'
LEFT JOIN
	(
		SELECT
			prod.CENTER,
			prod.GLOBALID,
			join_prod.needs_privilege,
			prod.blocked,
			prod.price,
			prod.name			
		FROM
			PRODUCTS prod
		LEFT JOIN SUBSCRIPTIONTYPES join_st
		ON
			prod.CENTER = join_st.CENTER
			AND prod.ID = join_st.ID
		LEFT JOIN PRODUCTS join_prod
		ON
			join_prod.CENTER = join_st.CENTER
			AND join_prod.id = join_st.PRODUCTNEW_ID
	)
	p3
ON
	per.CENTER = p3.center
	AND p3.blocked = 0
	AND p3.needs_privilege = 0
	AND p3.GLOBALID = 'EFT_12_M_LOCAL_AREA'
LEFT JOIN
	(
		SELECT
			prod.CENTER,
			prod.GLOBALID,
			join_prod.needs_privilege,
			prod.blocked,
			prod.price,
			prod.name			
		FROM
			PRODUCTS prod
		LEFT JOIN SUBSCRIPTIONTYPES join_st
		ON
			prod.CENTER = join_st.CENTER
			AND prod.ID = join_st.ID
		LEFT JOIN PRODUCTS join_prod
		ON
			join_prod.CENTER = join_st.CENTER
			AND join_prod.id = join_st.PRODUCTNEW_ID
	)
	p4
ON
	per.CENTER = p4.center
	AND p4.blocked = 0
	AND p4.needs_privilege = 0
	AND p4.GLOBALID = 'CASH_12_M_LOCAL_AREA'
LEFT JOIN
	(
		SELECT
			prod.CENTER,
			prod.GLOBALID,
			join_prod.needs_privilege,
			prod.blocked,
			prod.price,
			prod.name			
		FROM
			PRODUCTS prod
		LEFT JOIN SUBSCRIPTIONTYPES join_st
		ON
			prod.CENTER = join_st.CENTER
			AND prod.ID = join_st.ID
		LEFT JOIN PRODUCTS join_prod
		ON
			join_prod.CENTER = join_st.CENTER
			AND join_prod.id = join_st.PRODUCTNEW_ID
	)
	p5
ON
	per.CENTER = p5.center
	AND p5.blocked = 0
	AND p5.needs_privilege = 0
	AND p5.GLOBALID = 'EFT_12_M_AREA'
LEFT JOIN
	(
		SELECT
			prod.CENTER,
			prod.GLOBALID,
			join_prod.needs_privilege,
			prod.blocked,
			prod.price,
			prod.name			
		FROM
			PRODUCTS prod
		LEFT JOIN SUBSCRIPTIONTYPES join_st
		ON
			prod.CENTER = join_st.CENTER
			AND prod.ID = join_st.ID
		LEFT JOIN PRODUCTS join_prod
		ON
			join_prod.CENTER = join_st.CENTER
			AND join_prod.id = join_st.PRODUCTNEW_ID
	)
	p6
ON
	per.CENTER = p6.center
	AND p6.blocked = 0
	AND p6.needs_privilege = 0
	AND p6.GLOBALID = 'CASH_12_MONTH_AREA'


WHERE
    sub.center in (:ChosenScope)
    AND sub.END_DATE IS NOT NULL
    AND sub.END_DATE >= :FromDate
    AND sub.END_DATE < :ToDate + 1
--	AND prod.PRICE > 0
	AND sub.center not in (100, 21, 56, 57, 33, 34, 6) -- Exclude these centers
	AND per.persontype not in (2) -- Exclude Staff
--	AND per.persontype not in (2,4)
	AND UPPER(prod.NAME) NOT LIKE ('%BAD%')
	AND UPPER(prod.NAME) NOT LIKE ('%LIFESTYLE%')
	AND UPPER(prod.NAME) NOT LIKE ('%JUNIOR%')
	AND UPPER(prod.NAME) NOT LIKE ('%BARN%')
	AND trunc(months_between(TRUNC(exerpsysdate()), per.birthdate)/12) > 17
	AND subType.ST_TYPE = 0 -- Only Cashmembership

ORDER BY per.center, per.id