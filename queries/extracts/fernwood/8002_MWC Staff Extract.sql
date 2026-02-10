-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.firstname AS "First Name"
        ,p.lastname AS "Last name"
        ,p.birthdate AS "Birthdate"
        ,email.txtvalue AS "Email"
        ,p.external_id AS "ExternalId"
        ,p.center || 'p' || p.id AS "PersonKey"
        ,pea.txtvalue AS "StaffUserId"  
        ,p.Center AS "Person CenterId"
        ,e.center AS "Employee CenterId"
FROM 
        persons p
JOIN
        employees e ON p.center = e.personcenter AND p.id = e.personid AND e.blocked = 'false'
LEFT JOIN
        person_ext_attrs pea ON pea.personcenter = p.center AND pea.personid = p.id AND pea.NAME = '_eClub_WellnessCloudStaffUserId'
LEFT JOIN
        person_ext_attrs email
                ON email.personcenter = p.center
                AND email.personid = p.id
                AND email.name = '_eClub_Email'  