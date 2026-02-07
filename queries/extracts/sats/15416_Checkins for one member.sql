SELECT CONCAT(CONCAT(persons.center,'p' ),persons.id) AS PersonId,Firstname, Lastname, SSN, Checkin_Center, TO_DATE('01-01-1970','dd-mm-yyyy ') + Checkin_Time /(24*3600*1000) + 2/24 AS CheckinTime,persons.address1,persons.address2, persons.zipcode, z.city

FROM Checkin_Log 
JOIN Persons ON Checkin_log.center = Persons.Center AND Checkin_log.id = Persons.Id 
join zipcodes z on z.zipcode=persons.zipcode
and z.country =persons.country

WHERE persons.center = :Pcenter  AND 
persons.id = :Pid
AND
Checkin_time BETWEEN :startdate  +
:starthour * 60*60*1000 
AND :enddate + 
:endhour * 60*60*1000
ORDER BY CheckinTime
