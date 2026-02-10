-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	CONCAT(CONCAT(persons.center,'p' ),persons.id) AS PersonId,
	Firstname, 
	Lastname, 
	SSN, 
	Checkin_Center, 
to_char(longtodate(checkin_log.Checkin_Time), 'YYYY-MM-dd HH24:MI') AS CheckinTime

/*	TO_DATE('01-01-1970','dd-mm-yyyy ') + Checkin_Time /(24*3600*1000) + 2/24 AS CheckinTime */

FROM Checkin_Log 
JOIN Persons 
	ON 
	Checkin_log.center = Persons.Center 
	AND Checkin_log.id = Persons.Id 
WHERE 
	Checkin_Center in (:center)  
	AND Checkin_time BETWEEN :startdate  + :starthour * 60*60*1000 
	AND :enddate + :endhour * 60*60*1000
ORDER BY CheckinTime