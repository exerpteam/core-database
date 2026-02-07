/**
* Creator: Mikael Ahlberg
* Purpose: List all members that are considered to be a slow trainer.
* Member should have signed up three months ago and attended less than five times.
*
*/
SELECT DISTINCT
	p.CENTER || 'p' || p.ID AS PersonId,
	p.FULLNAME AS MEMBER_NAME,
	cen.NAME as CENTERNAME,
	CAST(EXTRACT('year' FROM age(p.birthdate)) AS VARCHAR) AS Age,
    CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PERSONTYPE,
    CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN' END PERSONSTATUS,
	TO_CHAR(p.BIRTHDATE, 'YYYY-MM-DD') AS BirthDate, 
	p.SEX,
    pea_mobile.TXTVALUE AS Mobile,
	prod.NAME,
	TO_CHAR(s.START_DATE, 'YYYY-MM-DD') AS StartDate,
	TO_CHAR(ADD_MONTHS( (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date, -3 ) + 1, 'YYYY-MM-DD') AS From_Startdate,
	TO_CHAR(ADD_MONTHS( (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date, -2 ), 'YYYY-MM-DD') AS To_Startdate,
	TO_CHAR(ADD_MONTHS( (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date, -3 ) + 1, 'YYYY-MM-DD HH24:MI') AS From_Checkindate,
	TO_CHAR(ADD_MONTHS( (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date, -1 ) + 3599/3600, 'YYYY-MM-DD HH24:MI') AS To_Checkindate,
	longtodate(per_att.MAX_START_TIME)                           AS last_Attendance,
	TO_CHAR(current_timestamp, 'YYYY-MM-DD') AS TODAY
	
FROM 
	PERSONS p

LEFT JOIN SUBSCRIPTIONS s 
ON  
	p.CENTER = s.OWNER_CENTER 
	AND p.ID = s.OWNER_ID 

LEFT JOIN SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.ID = s.SUBSCRIPTIONTYPE_ID

LEFT JOIN PRODUCTS prod
ON
    st.CENTER = prod.CENTER
    AND st.ID = prod.ID

LEFT JOIN PERSON_EXT_ATTRS pea_home
ON
    pea_home.PERSONCENTER = p.CENTER
	AND pea_home.PERSONID = p.ID
	AND pea_home.NAME = '_eClub_PhoneHome'

LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = p.CENTER
	AND pea_mobile.PERSONID = p.ID
	AND pea_mobile.NAME = '_eClub_PhoneSMS'

LEFT JOIN CENTERS cen
ON
	P.CENTER = cen.ID
		
LEFT JOIN
	(
	SELECT
		attends.PERSON_CENTER,
		attends.PERSON_ID,
		MAX(attends.START_TIME) AS MAX_START_TIME
	FROM
		ATTENDS attends
	WHERE
		attends.STATE = 'ACTIVE'
	GROUP BY
		attends.PERSON_CENTER,
		attends.PERSON_ID
	) per_att

ON
    per_att.PERSON_CENTER = p.CENTER
	AND per_att.PERSON_ID = p.ID
	

WHERE 
	p.CENTER IN (:ChosenScope) 
	AND EXISTS (
		SELECT 
			log.person_CENTER    as CENTER, 
			log.person_ID        as ID, 
			COUNT(*) as NB 
		FROM CHECKINs log
		WHERE  
			log.person_CENTER = p.CENTER
			AND log.person_ID = p.ID 
			AND CHECKIN_TIME BETWEEN datetolong(TO_CHAR(ADD_MONTHS( (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date, -3 ) + 1, 'YYYY-MM-DD HH24:MI')) AND datetolong(TO_CHAR(ADD_MONTHS( (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date, -1 ), 'YYYY-MM-DD HH24:MI'))  + 86399 * 1000 -- first to last, last month
		GROUP BY 
			log.person_CENTER, 
			log.person_ID 
		HAVING COUNT(*) <= 4 -- Less than five checkins is to be treated as slowstarter
	)
	AND s.START_DATE >= ADD_MONTHS( (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date, -3) + 1  -- first in month 2 months ago
	AND s.START_DATE <= ADD_MONTHS( (date_trunc('MONTH', now()) + INTERVAL '1 MONTH - 1 day')::date, -2 ) -- last in month 2 months ago
	AND p.STATUS = '1' -- Only active


