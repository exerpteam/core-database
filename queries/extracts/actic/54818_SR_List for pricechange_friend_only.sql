/* All subscriptions for pricechange*/

SELECT
	sub.center ||'ss'|| sub.id,
    per.center || 'p' || per.id personid,
    per.ssn,
	per.birthdate,
	(trunc(months_between(TRUNC(current_timestamp), per.birthdate)/12))::varchar age,
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
    CASE subType.ST_TYPE  WHEN 0 THEN  'KONTANT'  WHEN 1 THEN  'AUTOGIRO'  ELSE 'OTHERS' END as type,
	TO_CHAR(current_timestamp, 'YYYY-MM-DD') todays_date,
	(
		SELECT MAX(FROM_DATE) 
		FROM SUBSCRIPTION_PRICE pc 
		WHERE
			sub.CENTER = pc.SUBSCRIPTION_CENTER
			AND sub.ID = pc.SUBSCRIPTION_ID
	) AS LATEST_CHANGE
--	TO_CHAR(TRUNC(exerpsysdate() - 30), 'YYYY-MM-DD') sysdate_30,
--	TO_CHAR(ADD_MONTHS(exerpsysdate(), -3), 'YYYY-MM-DD') "-3 months"
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
WHERE
	per.CENTER IN (:scope) --Persons center
	AND per.STATUS IN ( :PersonStatus ) -- Only include some persontypes
	AND sub.STATE IN (2, 4, 8) -- Subscription Active or Created
	AND subType.ST_TYPE = 1 -- Only EFT
    AND sub.END_DATE IS NULL -- No end date (cancelled)
	AND per.PERSONTYPE IN (3) -- (FRIEND)

AND EXISTS ( SELECT 
					person_center, 
					person_id, 
					COUNT(*) as NB 
				FROM 
					CHECKINs 
				WHERE  
					CHECKINs.person_center = per.CENTER 
					 and 
					CHECKINs.person_id = per.ID 
					and CHECKIN_TIME BETWEEN :Check_in_from_date AND  :Check_in_To_date 
				GROUP BY 
					person_center, 
					person_id HAVING COUNT(*) BETWEEN :min AND :max )

ORDER BY per.center, per.id
