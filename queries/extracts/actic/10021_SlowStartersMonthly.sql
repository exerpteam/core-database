SELECT DISTINCT
	cen.EXTERNAL_ID AS Cost,
	P.CENTER || 'p' || P.ID AS PersonId,
	CAST(EXTRACT('year' FROM age(p.birthdate)) AS VARCHAR) AS Age,
    case P.PERSONTYPE when 0 then 'PRIVATE' when 1 then 'STUDENT' when 2 then 'STAFF' when 3 then 'FRIEND' when 4 then 'CORPORATE' when 5 then 'ONEMANCORPORATE' when 6 then 'FAMILY' when 7 then 'SENIOR' when 8 then 'GUEST' else 'UNKNOWN' end AS PERSONTYPE,
    case P.STATUS when 0 then 'LEAD' when 1 then 'ACTIVE' when 2 then 'INACTIVE' when 3 then 'TEMPORARYINACTIVE' when 4 then 'TRANSFERED' when 5 then 'DUPLICATE' when 6 then 'PROSPECT' when 7 then 'DELETED' else 'UNKNOWN' end as PERSONSTATUS,
	TO_CHAR(P.BIRTHDATE, 'YYYY-MM-DD') AS BirthDate, 
	P.SEX,
	TO_CHAR(S.START_DATE, 'YYYY-MM-DD') AS StartDate,
	TO_CHAR(date_trunc('month',current_timestamp - interval '2' month), 'YYYY-MM-DD') AS From_Startdate,
	TO_CHAR((date_trunc('month',current_timestamp - interval '1' month) - interval '1' day), 'YYYY-MM-DD') AS To_Startdate,
	TO_CHAR(date_trunc('month',current_timestamp - interval '1' month), 'YYYY-MM-DD HH24:MI') AS From_Checkindate,
	TO_CHAR((date_trunc('month', current_timestamp) - interval '1' minute), 'YYYY-MM-DD HH24:MI') AS To_Checkindate,
	TO_CHAR(current_timestamp, 'YYYY-MM-DD') AS TODAY
	

FROM 
	PERSONS P 
LEFT JOIN SUBSCRIPTIONS S 
ON  
	P.CENTER = S.OWNER_CENTER 
	AND P.ID = S.OWNER_ID 
LEFT JOIN CENTERS cen
ON
	P.CENTER = cen.ID
WHERE 
	P.CENTER IN (:ChosenScope) 
	AND EXISTS (
				SELECT 
					CHECKINS.person_CENTER,
					CHECKINS.person_ID, 
					COUNT(*) as NB 
				FROM 
					CHECKINS 
				WHERE  
					CHECKINS.person_CENTER = P.CENTER 
					and CHECKINs.person_ID = P.ID 
					and CHECKINS.CHECKIN_TIME BETWEEN datetolong(TO_CHAR(date_trunc('month',current_timestamp - interval '1' month), 'YYYY-MM-DD HH24:MI')) AND datetolong(TO_CHAR((date_trunc('month', current_timestamp) - interval '1' second), 'YYYY-MM-DD HH24:MI:SS'))-- first to last, last month
				GROUP BY 
					CHECKINS.person_CENTER, 
					CHECKINS.person_ID 
				HAVING 
					COUNT(*) <= 4
				)
	AND S.START_DATE >= date_trunc('month',current_timestamp - interval '2' month)  -- first in month 2 months ago
	AND S.START_DATE <= date_trunc('month',current_timestamp - interval '1' month) - interval '1' day -- last in month 2 months ago
