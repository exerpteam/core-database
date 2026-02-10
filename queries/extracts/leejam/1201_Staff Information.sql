-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        p.center || 'p' || p.id AS PersonId,
        CASE p.PERSONTYPE 
                WHEN 0 THEN 'PRIVATE' 
                WHEN 1 THEN 'STUDENT' 
                WHEN 2 THEN 'STAFF' 
                WHEN 3 THEN 'FRIEND' 
                WHEN 4 THEN 'CORPORATE' 
                WHEN 5 THEN 'ONEMANCORPORATE' 
                WHEN 6 THEN 'FAMILY' 
                WHEN 7 THEN 'SENIOR' 
                WHEN 8 THEN 'GUEST' 
                WHEN 9 THEN 'CHILD' 
                WHEN 10 THEN 'EXTERNAL_STAFF' 
                ELSE 'Undefined' 
        END AS Person_type,
        CASE p.STATUS 
                WHEN 0 THEN 'LEAD' 
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END AS Person_status,
        p.external_id AS PersonExternalID,
        emp.center || 'emp' || emp.id AS EmployeeId,
       	pet1.txtvalue AS StaffExternalID,
       	CASE
       	        WHEN emp.blocked = 1 THEN 'Blocked'
       	        ELSE 'Active'
        END AS EmployeeStatus,       	        
        c.shortname as "Person Home Club",
        p.firstname,
        p.lastname,
        pet.txtvalue AS Email,
        STRING_AGG(sg.name, ', ') AS "Staff Group",
        CASE
                WHEN empr.roleid = 0 THEN 'No role'
                ELSE STRING_AGG(r.rolename, ', ') 
        END AS "Role"
FROM
        leejam.employees emp
JOIN 
        leejam.persons p
                ON emp.personcenter = p.center
                AND emp.personid = p.id         
JOIN
        leejam.centers c
                ON c.id = p.center                                              
LEFT JOIN 
        (SELECT
                emp.center
                ,emp.id
                ,CASE
                        WHEN r.id IS NULL THEN 0
                        ELSE r.id
                END AS roleid                
        FROM
                leejam.employees emp
        LEFT JOIN 
                leejam.employeesroles empr
                        ON empr.center = emp.center
                        AND empr.id = emp.id
        LEFT JOIN
                leejam.roles r
                        ON r.id = empr.roleid
                        AND r.is_action IS FALSE 
                        AND r.blocked IS FALSE                              
        )empr
                ON empr.center = emp.center
                AND empr.id = emp.id                        
LEFT JOIN
        leejam.roles r
                ON r.id = empr.roleid
                
LEFT JOIN
        leejam.person_ext_attrs pet
                ON pet.personcenter = p.center
                AND pet.personid = p.id
		AND pet.name = '_eClub_Email'
LEFT JOIN
        leejam.person_ext_attrs pet1
                ON pet1.personcenter = p.center
                AND pet1.personid = p.id
		AND pet1.name = '_eClub_StaffExternalId'
LEFT JOIN
        leejam.person_staff_groups psg
                ON psg.person_center = p.center
                AND psg.person_id = p.id 
				
LEFT JOIN
        leejam.staff_groups sg
                ON sg.id = psg.staff_group_id
WHERE
        emp.blocked IN (:Employee_status) -- 0 not blocked 1 blocked
                 
GROUP BY 
        p.center,
        p.id,
        emp.center,emp.id,
        emp.external_id,
        c.shortname,
        p.firstname,
        p.lastname,
        pet.txtvalue,
        pet1.txtvalue,
        empr.roleid

        