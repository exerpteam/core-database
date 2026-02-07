/* Only centers with max cards */

SELECT
    per.center || 'p' || per.id personid,
    per.ssn,
	per.birthdate,
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
    cen.NAME CLUB,
    TO_CHAR(sub.END_DATE, 'YYYY-MM-DD') end_DATE,
    TO_CHAR(sub.END_DATE + 1, 'YYYY-MM-DD') new_DATE,
    prod.PRICE currentProdPrice,
    sub.SUBSCRIPTION_PRICE currentMemberPrice,
    prod.NAME,

	/* Calculate EFT_LOCAL price based upon erlier price
    CASE
        WHEN subType.ST_TYPE = 0 and sub.SUBSCRIPTION_PRICE = 0
        THEN defaultprod_eft.PRICE

        WHEN subType.ST_TYPE = 0 and sub.SUBSCRIPTION_PRICE <= prod.PRICE * 0.60
        THEN round(defaultprod_eft.PRICE * 0.75)

        WHEN subType.ST_TYPE = 1 and sub.SUBSCRIPTION_PRICE <= prod.PRICE * 0.60
        THEN round(defaultprod_eft.PRICE * 0.75) 

        ELSE defaultprod_eft.PRICE
    END AG_PRICE,
	*/
	
	/* If maxcard price is < 100 then present local card. 
	* Check if persontype is Senior then trunc price.
	* Done twice for eft and cash in two columns
    CASE
    	WHEN defaultprod_max_cash.PRICE < 100 THEN 
    	(CASE WHEN per.PERSONTYPE = 7 THEN trunc(defaultprod_cash.PRICE * 0.70, -2) + 95
    		ELSE defaultprod_cash.PRICE
    	END)
    	WHEN per.PERSONTYPE = 7 THEN trunc(defaultprod_max_cash.PRICE * 0.70, -2) + 95
    		ELSE defaultprod_max_cash.PRICE
    END CASH_PRICE,
    
    CASE
    	WHEN defaultprod_max_eft.PRICE < 100 THEN 
    	(CASE WHEN per.PERSONTYPE = 7 THEN trunc(defaultprod_eft.PRICE * 0.70, -1) + 9
    		ELSE defaultprod_eft.PRICE
    	END)
    	WHEN per.PERSONTYPE = 7 THEN trunc(defaultprod_max_eft.PRICE * 0.70, -1) + 9
    		ELSE defaultprod_max_eft.PRICE
    END EFT_PRICE,  	
	*/  
    	
	/* SENOR TEST CASE */
	CASE
		WHEN per.PERSONTYPE = 7
		THEN trunc(defaultprod_max_eft.PRICE * 0.70, -1) + 9
		
		ELSE defaultprod_max_eft.PRICE
	END EFT_12_M_AREA,
	CASE
		WHEN per.PERSONTYPE = 7
		THEN trunc(defaultprod_max_cash.PRICE * 0.70, -2) + 95
		
		ELSE defaultprod_max_cash.PRICE
	END CASH_12_M_AREA,
	/* END SENIOR TEST CASE */	

    DECODE(subType.ST_TYPE, 0, 'KONTANT', 1, 'AUTOGIRO') type,
	pem.txtvalue AS email
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
JOIN PRODUCTS defaultprod_max_eft
ON
    per.CENTER = defaultprod_max_eft.CENTER
    AND defaultprod_max_eft.GLOBALID = 'EFT_12_M_AREA'
JOIN PRODUCTS defaultprod_max_cash
ON
    per.CENTER = defaultprod_max_cash.CENTER
    AND defaultprod_max_cash.GLOBALID = 'CASH_12_MONTH_AREA'
left join person_ext_attrs pem 
on 
	pem.personcenter = per.center 
	and pem.personid = per.id 
	and pem.name = '_eClub_Email' 
WHERE
    sub.center in (:ChosenScope)
    AND sub.END_DATE IS NOT NULL
    AND sub.END_DATE >= :FromDate
    AND sub.END_DATE < :ToDate + 1
    AND prod.PRICE > 0
    AND sub.center not in (100, 21, 56, 57, 33, 34)
	AND sub.center in (102, 174, 179, 24, 182, 154, 19, 181)
	AND per.persontype not in (2,4)
	AND UPPER(prod.NAME) NOT LIKE ('%BAD%')
	AND UPPER(prod.NAME) NOT LIKE ('%LIFESTYLE%')
	AND UPPER(prod.NAME) NOT LIKE ('%JUNIOR%')
	AND UPPER(prod.NAME) NOT LIKE ('%BARN%')
	AND trunc(months_between(TRUNC(exerpsysdate()), per.birthdate)/12) > 17
	AND subType.ST_TYPE = 0


ORDER BY per.center, per.id