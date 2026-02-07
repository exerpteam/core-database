/* All students with ssn*/

SELECT
    cen.NAME CLUB,
	per.center,
    per.center || 'p' || per.id personid,
    per.ssn,
	per.birthdate,
	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()), per.birthdate)/12)) age,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') PERSONTYPE, 
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') PERSONSTATUS,
    per.FIRSTNAME,
    per.LASTNAME,
    per.ADDRESS1,
    per.ADDRESS2,
    per.ZIPCODE,
    per.CITY,
    DECODE(subType.ST_TYPE, 0, 'KONTANT', 1, 'AUTOGIRO') currenttype,
	TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD') todays_date
FROM
    PERSONS per
JOIN centers cen
ON
    cen.ID = per.CENTER
LEFT JOIN SUBSCRIPTIONS sub
ON
	sub.OWNER_CENTER = per.CENTER
	AND sub.OWNER_ID = per.ID
LEFT JOIN SUBSCRIPTIONTYPES subType
ON
    subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
    AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
WHERE
	per.CENTER IN (:ChosenScope)
	AND floor(months_between(exerpsysdate(), "BIRTHDATE") / 12) BETWEEN :ageFrom AND  :ageTo
	AND per.STATUS IN ( :PersonStatus )

				
ORDER BY per.center, per.id