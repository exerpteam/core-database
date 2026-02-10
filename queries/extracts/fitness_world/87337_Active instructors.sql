-- The extract is extracted from Exerp on 2026-02-08
--  
select distinct 
su.person_center ||'p'|| su.person_id as INSTRUCTOR_PERSON_ID, p.external_id AS EXTERNAL_ID, p.FULLNAME as INSTRUCTOR_NAME, pea.txtvalue AS EMAIL
from bookings b
left join staff_usage su
on b.center = su.booking_center and b.id = su.booking_id
left join persons p
on su.person_center = p.center AND su.person_id = p.id
left join EMPLOYEES e 
ON p.CENTER = e.PERSONCENTER AND p.ID = e.PERSONID
LEFT JOIN PERSON_EXT_ATTRS pea
ON pea.PERSONCENTER = p.center
AND pea.PERSONID = p.id
AND pea.NAME = '_eClub_Email'
WHERE p.FULLNAME IS NOT NULL
AND p.external_id IS NOT NULL
AND p.status in (1,4)
AND p.persontype = 2
--AND su.STATE != 'CANCELLED'
