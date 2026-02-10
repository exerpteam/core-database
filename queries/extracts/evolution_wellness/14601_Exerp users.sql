-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.firstname,
        p.lastname,
        p.external_id,
        c.name as "center",
        e.center ||'emp'|| e.id AS "username",
        e.last_login,
        CASE
                WHEN e.blocked IS TRUE THEN 'BLOCKED'
                ELSE 'ACTIVE'
        END AS "Login Status",        
        CASE
                WHEN er.scope_type = 'G' AND er.scope_id = 0 THEN 'System'
                WHEN er.scope_type = 'C' THEN cc.shortname 
                WHEN er.scope_type = 'T' AND er.scope_id = 1 THEN 'Global'
                WHEN er.scope_type = 'A' THEN a.name
                ELSE 'To be mapped'
        END AS scope,
        email.*      
FROM
        employees e
JOIN 
        persons p
        ON p.id = e.personid 
        AND p.center = e.personcenter
JOIN 
        centers c
        ON c.id = e.center
JOIN 
        employeesroles er
        ON er.id = e.id 
        AND er.center = e.center
JOIN 
        roles r
        ON r.id = er.roleid
LEFT JOIN
        centers cc
        ON cc.id = er.scope_id
        AND er.scope_type = 'C' 
LEFT JOIN
        areas a
        ON a.id = er.scope_id
LEFT JOIN
        person_ext_attrs email
        ON email.personcenter = p.center
        AND email.personid = p.id 
        AND email.name = '_eClub_Email'
                      
WHERE
        p.status NOT IN (7,8)
        AND e.center != 1
        AND er.roleid = 539
        AND e.center in (:scope)