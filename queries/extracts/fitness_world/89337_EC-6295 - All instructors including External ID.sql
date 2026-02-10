-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    (psg.person_center || 'p' || psg.person_id) AS "INSTRUCTOR",
    p.fullname                                  AS "NAME",
    CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 
    'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "PERSONSTATUS",
    current_person.external_id AS "EXTERNAL_ID"
FROM
    PERSON_STAFF_GROUPS psg
JOIN
    persons p
ON
    psg.person_center = p.center
AND psg.person_id = p.id
JOIN
persons current_person
ON
current_person.center = p.current_person_center
AND current_person.id = p.current_person_id
LEFT JOIN
    STAFF_GROUPS sg
ON
    psg.staff_group_id = sg.id
WHERE
p.center IN (:scope)
AND p.fullname IS NOT NULL