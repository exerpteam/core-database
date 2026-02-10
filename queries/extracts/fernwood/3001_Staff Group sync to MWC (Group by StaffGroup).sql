-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1.PersonId,
        t1.external_id,
        t1.firstname,
        t1.lastname,
        t1.Email,
        COUNT(*) AS StaffGroupTotal
FROM
(
        SELECT
                distinct
                p.center || 'p' || p.id AS PersonId,        
                p.external_id,
                p.firstname,
                p.lastname,
                pea.txtvalue AS Email,
                sgc.id
                                
        FROM
                persons p
        JOIN
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
) t1
GROUP BY
        t1.PersonId,
        t1.external_id,
        t1.firstname,
        t1.lastname,
        t1.Email
ORDER BY 6 DESC
        