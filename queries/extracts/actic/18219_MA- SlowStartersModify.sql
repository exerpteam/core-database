SELECT DISTINCT
	cen.EXTERNAL_ID AS Cost,
	P.CENTER || 'p' || P.ID AS PersonId,
	P.Fullname,
	CEN.NAME as CENTERNAME,
	TO_CHAR(trunc(months_between(TRUNC(exerpsysdate()), p.birthdate)/12)) AS Age,
    DECODE (P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    DECODE (P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') PERSONSTATUS,
	TO_CHAR(P.BIRTHDATE, 'YYYY-MM-DD') AS BirthDate, 
	P.SEX,
	pea_home.txtvalue   AS Phone,
    pea_mobile.txtvalue AS Mobile,
	TO_CHAR(S.START_DATE, 'YYYY-MM-DD') AS StartDate,
	TO_CHAR(ADD_MONTHS( LAST_DAY(exerpsysdate()), -3 ) + 1, 'YYYY-MM-DD') AS From_Startdate,
	TO_CHAR(ADD_MONTHS( LAST_DAY(exerpsysdate()), -2 ), 'YYYY-MM-DD') AS To_Startdate,
	TO_CHAR(ADD_MONTHS( LAST_DAY(TRUNC(exerpsysdate())), -3 ) + 1, 'YYYY-MM-DD HH24:MI') AS From_Checkindate,
	TO_CHAR(ADD_MONTHS( LAST_DAY(TRUNC(exerpsysdate())), -1 ) + 3599/3600, 'YYYY-MM-DD HH24:MI') AS To_Checkindate,
	TO_CHAR(exerpsysdate(), 'YYYY-MM-DD') AS TODAY
	

FROM 
	PERSONS P 


LEFT JOIN SUBSCRIPTIONS S 
ON  
	P.CENTER = S.OWNER_CENTER 
	AND P.ID = S.OWNER_ID 

LEFT JOIN PERSON_EXT_ATTRS pea_home
ON
    pea_home.PERSONCENTER = p.center
AND pea_home.PERSONID = p.id
AND pea_home.NAME = '_eClub_PhoneHome'

LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = p.center
AND pea_mobile.PERSONID = p.id
AND pea_mobile.NAME = '_eClub_PhoneSMS'

LEFT JOIN CENTERS cen
ON
	P.CENTER = cen.ID

WHERE 
	P.CENTER IN (:ChosenScope) 
	AND EXISTS (
				SELECT 
					CENTER, 
					ID, 
					COUNT(*) as NB 
				FROM 
					CHECKIN_LOG 

				WHERE  
				CHECKIN_LOG.CENTER =P.CENTER
					 AND CHECKIN_LOG.ID = P.ID 
					AND CHECKIN_TIME BETWEEN datetolong(TO_CHAR(ADD_MONTHS( LAST_DAY(TRUNC(exerpsysdate())), -3 ) + 1, 'YYYY-MM-DD HH24:MI')) AND datetolong(TO_CHAR(ADD_MONTHS( LAST_DAY(TRUNC(exerpsysdate())), -1 ), 'YYYY-MM-DD HH24:MI'))  + 86399 * 1000 -- first to last, last month
				GROUP BY 
					CENTER, 
					ID 
				HAVING 
					COUNT(*) <= 4
				)
	AND S.START_DATE >= ADD_MONTHS( LAST_DAY(TRUNC(exerpsysdate())), -3) + 1  -- first in month 2 months ago
	AND S.START_DATE <= ADD_MONTHS( LAST_DAY(TRUNC(exerpsysdate())), -2 ) -- last in month 2 months ago
	AND p.status = '1'