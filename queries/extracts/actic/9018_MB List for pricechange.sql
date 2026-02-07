/* All subscriptions for pricechange*/

SELECT
    per.center || 'p' || per.id personid,
	(select c.lastname from persons c where c.center = r.center and c.id = r.id ) as companyname, 
    per.ssn,
	per.birthdate,
	CAST(EXTRACT('year' FROM age(per.birthdate)) AS VARCHAR) AS age,
    CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END PERSONTYPE, 
    CASE  per.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN' END PERSONSTATUS,
    CASE  sub.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END subscription_STATE,
    CASE  sub.SUB_STATE  WHEN 1 THEN 'NONE'  WHEN 2 THEN 'AWAITING_ACTIVATION'  WHEN 3 THEN 'UPGRADED'  WHEN 4 THEN 'DOWNGRADED'  WHEN 5 THEN 'EXTENDED'  WHEN 6 THEN  'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' ELSE 'UNKNOWN' END  SUBSCRIPTION_SUB_STATE,
    per.FIRSTNAME,
    per.LASTNAME,
    per.ADDRESS1,
    per.ADDRESS2,
    per.ZIPCODE,
    per.CITY,
    cen.NAME CLUB,
	TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') start_DATE,
	TO_CHAR(sub.BINDING_END_DATE, 'YYYY-MM-DD') binding_end_DATE,
    TO_CHAR(sub.END_DATE, 'YYYY-MM-DD') end_DATE,
    prod.PRICE currentProdPrice,
    sub.SUBSCRIPTION_PRICE currentMemberPrice,
    prod.NAME,
    CASE subType.ST_TYPE  WHEN 0 THEN  'KONTANT'  WHEN 1 THEN  'AUTOGIRO' END as type,
	TO_CHAR(TRUNC(current_timestamp), 'YYYY-MM-DD') todays_date
--	TO_CHAR(TRUNC(current_timestamp - 30), 'YYYY-MM-DD') current_timestamp_30,
--	TO_CHAR(ADD_MONTHS(current_timestamp, -3), 'YYYY-MM-DD') "-3 months"
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
LEFT JOIN relatives r 
ON 
	per.center = r.relativecenter 
	AND per.id = r.relativeid 
	AND r.rtype = 2 
	AND r.status <> 3 
WHERE
	per.CENTER IN (:Center)
	AND per.STATUS IN ( :PersonStatus )
	AND sub.STATE IN (2, 8)
	AND subType.ST_TYPE = 1
    AND sub.END_DATE IS NULL
	AND sub.BINDING_END_DATE < (current_timestamp)
	AND UPPER(prod.NAME) NOT LIKE ('%BAD%')
	AND UPPER(prod.NAME) NOT LIKE ('%LIFESTYLE%')
	AND UPPER(prod.NAME) NOT LIKE ('%JUNIOR%')
	AND UPPER(prod.NAME) NOT LIKE ('%BARN%')
	AND UPPER(prod.NAME) LIKE ('%12%')
	AND per.PERSONTYPE IN (0, 4)
	AND (CAST(EXTRACT('year' FROM age(per.birthdate)) AS INT) < 60 OR per.birthdate IS NULL)
	AND EXISTS ( SELECT 
					checkins.person_CENTER, 
					checkins.person_ID, 
					COUNT(*) as NB 
				FROM 
					CHECKINs
				WHERE  
					checkins.person_CENTER = per.CENTER 
					and checkins.person_id = per.ID 
					and CHECKIN_TIME BETWEEN :Check_in_from_date AND  :Check_in_To_date 
				GROUP BY 
					checkins.person_CENTER, 
					checkins.person_ID HAVING COUNT(*) BETWEEN :min AND :max )
				
ORDER BY per.center, per.id