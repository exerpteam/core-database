-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS PersonId,
        c.shortname as "Home Club",
        p.external_id,
        p.firstname,
        p.lastname,
        emp.center ||'emp'||emp.id AS "Employee ID",
        cemp.shortname AS "Employee Club",
        sgc.name As Scope,
        sg.name AS "Staff Group"    
FROM
        persons p
LEFT JOIN
        employees emp
                ON emp.personcenter = p.center
                AND emp.personid = p.id
                AND emp.blocked = 'false'
LEFT JOIN
        centers cemp
                ON cemp.id = emp.center
LEFT JOIN
        centers c
                ON c.id = p.center                                              
LEFT JOIN
        person_staff_groups psg
                ON psg.person_center = p.center
                AND psg.person_id = p.id 
LEFT JOIN
        staff_groups sg
                ON sg.id = psg.staff_group_id
LEFT JOIN 
        centers sgc
                ON sgc.id = psg.scope_id                                   
WHERE
    p.persontype = 2
    AND 
    p.status not in (4,5,7,8)
ORDER BY
    2,1