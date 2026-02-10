-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Extract to list active members that have visited any facility the last 30 days.
* Initialize values with fromDate 30 days earlier than toDate.
*/

WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) - (30 * 24 * 60 * 60 * 1000) AS fromDate,
                datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )

SELECT 
	longtodate(fromDate),
	longtodate(toDate),
	CE.ID, 
	CE.NAME, 
	COUNT(DISTINCT P.CENTER || 'p' || P.ID) AS MEMBERS
FROM PERSONS P LEFT 
JOIN SUBSCRIPTIONS S ON 
	P.CENTER = S.OWNER_CENTER 
	AND P.ID = S.OWNER_ID
LEFT JOIN CENTERS CE ON 
	P.CENTER = CE.ID 
LEFT 
	JOIN PARAMS params ON 
	params.CenterID = P.CENTER
WHERE S.STATE = 2

AND EXISTS ( 
	SELECT CENTER, ID, COUNT(*) as NB 
FROM CHECKIN_LOG 
WHERE 
	CHECKIN_LOG.CENTER = P.CENTER and 
	CHECKIN_LOG.ID = P.ID AND 
	CHECKIN_TIME BETWEEN 
		params.fromDate AND  
		params.toDate
GROUP BY CENTER, ID 
HAVING COUNT(*) >= 1)
GROUP BY longtodate(fromDate),	longtodate(toDate),CE.ID,CE.NAME