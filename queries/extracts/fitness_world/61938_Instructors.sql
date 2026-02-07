-- This is the version from 2026-02-05
--  
Select distinct(psg.person_center || 'p' || psg.person_id) AS INSTRUCTOR,
p.fullname AS NAME,
CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSONSTATUS
FROM PERSON_STAFF_GROUPS psg
left join persons p
on psg.person_center = p.center and psg.person_id = p.id
left join STAFF_GROUPS sg
on psg.staff_group_id = sg.id
Where
p.status = 1
AND p.center in (:scope)
