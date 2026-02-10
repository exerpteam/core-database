-- The extract is extracted from Exerp on 2026-02-08
--  
select distinct
b.CENTER ||'book'|| b.ID as "BOOKING_ID",
b.NAME as "BOOKING_NAME",
to_char (longtodate(b.starttime), 'dd-MM-YYYY HH24:MI') AS "STARTTIME",
su.person_center ||'p'|| su.person_id as "INSTRUCTOR_PERSON_ID",
--e.CENTER ||'emp'|| e.ID as INSTRUCTOR_EMPLOYEE_ID,
p.FULLNAME as "INSTRUCTOR_NAME"
from bookings b
left join staff_usage su
on b.center = su.booking_center and b.id = su.booking_id
left join persons p
on su.person_center = p.center AND su.person_id = p.id
left join EMPLOYEES e 
ON p.CENTER = e.PERSONCENTER AND p.ID = e.PERSONID
Where 
b.STATE = 'ACTIVE'
AND longtodate(b.starttime) >= (current_timestamp-80)
AND b.conflict = 0
AND b.CENTER in (:scope)
AND su.STATE != 'CANCELLED'
