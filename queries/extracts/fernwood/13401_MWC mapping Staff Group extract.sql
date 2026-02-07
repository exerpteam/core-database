SELECT
        p.center || 'p' || p.id AS PersonId,
        c.shortname as "Person Home Club",
        p.firstname,
        p.lastname,
        sgc.name As "Staff Group Scope",
        sg.name AS "Staff Group"   
FROM
        fernwood.persons p
JOIN
        fernwood.centers c
                ON c.id = p.center                                              
JOIN
        fernwood.person_staff_groups psg
                ON psg.person_center = p.center
                AND psg.person_id = p.id 
				AND psg.staff_group_id in (9,4,11,1001)
JOIN
        fernwood.staff_groups sg
                ON sg.id = psg.staff_group_id
JOIN 
        fernwood.centers sgc
                ON sgc.id = psg.scope_id                                   
WHERE
    p.persontype = 2
    AND 
    p.status not in (4,5,7,8)
ORDER BY
    2,1