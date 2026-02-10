-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    TO_CHAR(longtodateC(c.checkin_time, c.person_center), 'DD-MM-YYYY') AS "Attendance Day" ,
	TO_CHAR(longtodateC(c.checkin_time, c.person_center), 'HH24:MI:SS') AS "Checkin Time",
	p.fullname AS "Full Name",
phonenumber.txtvalue AS "Phone Number",
email.txtvalue AS "Email Address"
FROM CHECKINS c
	join persons p
	on p.center = c.person_center
	and p.id = c.person_id
  LEFT JOIN PERSON_EXT_ATTRS phonenumber 
    ON p.center = phonenumber.personcenter 
   AND p.id = phonenumber.personid 
   AND phonenumber.name = '_eClub_PhoneSMS'
LEFT JOIN PERSON_EXT_ATTRS email 
    ON p.center = email.personcenter 
   AND p.id = email.personid 
   AND email.name = '_eClub_Email'
WHERE  c.checkin_time >= EXTRACT(EPOCH FROM ($$CreationFrom$$::TIMESTAMP AT TIME ZONE 'Australia/Sydney')) * 1000
    AND c.checkin_time < (EXTRACT(EPOCH FROM $$CreationTo$$::TIMESTAMP AT TIME ZONE 'Australia/Sydney') * 1000 + 86400000)
	AND c.checkin_center in ($$scope$$)