-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT 
         p.center ||'p'||p.id AS "Person ID"
         ,p.firstname AS "First Name"
         ,p.lastname AS "Last Name"
         ,p.birthdate AS "DOB"
         ,pea.txtvalue AS "Email"
         ,emp.center ||'emp'||emp.id as "Employee ID"
         ,p.external_id AS "External ID"
         ,c.name AS "Employee Home CLub"
         ,ce.name AS "Employee Club"
         ,case
                when sg.external_reference is null then 'No'
                Else 'Yes'
         END AS "PMW Staff"
         ,oldID.txtvalue AS "Legacy ID"
FROM employees emp
JOIN persons p
        ON p.center = emp.personcenter
        AND p.id = emp.personid
JOIN centers c  
        ON c.id = p.center
JOIN centers ce
        ON emp.center = ce.id
LEFT JOIN person_ext_attrs pea
        ON pea.personcenter = p.center
        AND pea.personid = p.id 
        AND pea.name = '_eClub_Email' 
LEFT JOIN person_staff_groups psg
        ON p.center = psg.person_center
        AND p.id = psg.person_id 
LEFT JOIN staff_groups sg
        ON sg.id = psg.staff_group_id  
LEFT JOIN person_ext_attrs oldID
        ON oldID.personcenter = p.center
        AND oldID.personid = p.id   
        AND oldID.name = '_eClub_OldSystemPersonId'                      
WHERE
        emp.blocked = 'false'
		and
		p.status not in (4,5,7,8)
order by 2,3,1