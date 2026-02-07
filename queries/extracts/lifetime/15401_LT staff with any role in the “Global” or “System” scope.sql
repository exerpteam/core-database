
SELECT
    r.rolename AS r_rolename,
    p.external_id,
    p.fullname AS user_name,
    CASE p.status
        WHEN 0
        THEN 'LEAD'
        WHEN 1
        THEN 'ACTIVE'
        WHEN 2
        THEN 'INACTIVE'
        WHEN 3
        THEN 'TEMPORARYINACTIVE'
        WHEN 4
        THEN 'TRANSFERRED'
        WHEN 5
        THEN 'DUPLICATE'
        WHEN 6
        THEN 'PROSPECT'
        WHEN 7
        THEN 'DELETED'
        WHEN 8
        THEN 'ANONYMIZED'
        WHEN 9
        THEN 'CONTACT'
        ELSE 'Undefined'
    END AS PERSON_STATUS,
    e.last_login ,
    er.scope_type AS er_scopetype,
    er.scope_id   AS scopeid,
    e.blocked
    --, *
FROM
    persons p
JOIN
    EMPLOYEES e
ON
    p.center = e.personcenter
AND p.id =e.personid
LEFT JOIN
    EMPLOYEESROLES er
ON
    e.center = er.center
AND e.id = er.id
JOIN
    ROLES r
ON
    er.roleid = r.id
LEFT JOIN
    centers c
ON
    er.scope_id = c.id
WHERE
    r.rolename  != 'Exerp'
AND 
e.blocked = 'false'
AND p.status NOT IN (7,8)
and er.scope_type in ('G','T')
and er.scope_id in (0,1)
and upper(p.fullname) not like upper('%Exerp%')
GROUP BY
    r.rolename,
    p.external_id,
    c.name,
    p.fullname,
    p.status,
    e.last_login ,
    er.scope_type,
    e.blocked,
    er.scope_id ;
