-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    'Fernwood' as client,
    p.center||'p'||p.id as member_key,
    e.center||'emp'||e.id as employee_key,
p.fullname,
    pea_email.txtvalue as email
     
FROM persons p 
JOIN EMPLOYEES e                ON p.center = e.personcenter AND p.id = e.personid 
JOIN EMPLOYEESROLES er          ON e.center = er.center AND e.id = er.id 
JOIN ROLES r                    ON er.roleid = r.id 
LEFT JOIN person_ext_attrs pea_email ON pea_email.personcenter = p.center AND pea_email.personid = p.id AND pea_email.name IN ('_eClub_Email') 
WHERE 
    r.system_id = 16 
    AND r.is_action = false 
    AND p.status NOT IN (7, 8) 
    AND e.blocked = 0 
    AND e.center||'emp'||e.id != '100emp1' 