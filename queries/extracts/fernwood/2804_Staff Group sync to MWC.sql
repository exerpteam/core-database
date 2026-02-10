-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center || 'p' || p.id AS PersonId,        
        p.external_id,
        p.firstname,
        p.lastname,
        pea.txtvalue AS Email,
     	sgc.shortname AS staffgroupcenter,
        sgc.id StaffGroupcenterID,
        sgc.facility_url As StaffGroupFacilityURL,
        sg.name AS "Staff Group",
        sg.external_reference
        
FROM
        persons p
LEFT JOIN
        centers c
                ON c.id = p.center                                              
JOIN
        person_staff_groups psg
                ON psg.person_center = p.center
                AND psg.person_id = p.id 
JOIN
        staff_groups sg
                ON sg.id = psg.staff_group_id
                AND sg.external_reference is not NULL
                AND sg.external_reference != ''
JOIN 
        centers sgc
                ON sgc.id = psg.scope_id     
LEFT JOIN
        person_ext_attrs pea
                ON pea.personcenter = p.center
                AND pea.personid = p.id
                AND pea.name = '_eClub_Email'                                              
WHERE
    p.persontype = 2
    AND 
    p.status not in (4,5,7,8)
ORDER BY
    2,1