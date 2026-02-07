SELECT CONCAT(CONCAT(persons.center,'p' ),persons.id) AS PersonId,
Firstname, 
Lastname, 
SSN,
 Checkin_Center, 
TO_DATE('01-01-1970','dd-mm-yyyy ') + Checkin_Time /(24*3600*1000) + 2/24 AS CheckinTime

FROM Checkin_Log 
JOIN Persons ON Checkin_log.center = Persons.Center AND Checkin_log.id = Persons.Id 

WHERE Checkin_Center between :center and :center2
and/* checkin_center <> persons.center  AND */
Checkin_time BETWEEN :startdate  +
:starthour * 60*60*1000 
AND :enddate + 
:endhour * 60*60*1000
ORDER BY CheckinTime
