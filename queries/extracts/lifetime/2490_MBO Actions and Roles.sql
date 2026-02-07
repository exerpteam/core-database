SELECT
    r.rolename,
    a.rolename,
    a.is_action
FROM
    impliedemployeeroles ir
JOIN
    roles r
ON
    ir.roleid=r.id
JOIN
    roles a
ON
    ir.implied=a.id
WHERE
    r.blocked=false
AND a.blocked=false
GROUP BY
    ir.roleid,
    r.id,
    ir.implied,
    a.id
ORDER BY
    a.rolename,
    r.rolename