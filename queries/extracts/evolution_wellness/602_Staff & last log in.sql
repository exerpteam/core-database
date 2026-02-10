-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.firstname,
        p.lastname,
        p.external_id,
        c.name as "center",
        e.center ||'emp'|| e.id AS "username",
        e.last_login,
        p.country AS "Country Code",
        e.passwd_expiration,
        e.passwd_never_expires
FROM employees e
JOIN persons p
        ON p.id = e.personid 
        AND p.center = e.personcenter
JOIN centers c
        ON c.id = e.center
WHERE
        p.status NOT IN (4,5,7,8)
        AND e.blocked = false
        AND NOT EXISTS
        (
                SELECT 1
                FROM evolutionwellness.employeesroles er
                WHERE
                        er.center = e.center
                        AND er.id = e.id
                        AND er.roleid = 539
        )

