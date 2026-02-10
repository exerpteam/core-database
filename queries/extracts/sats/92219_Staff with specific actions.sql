-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
t.employee_id,
t.expiration_date,
t.fullname,
CASE
WHEN t.role_action IS NULL
THEN t.action
WHEN t.is_action IS false
THEN t.role_action
END AS action,
t.last_login
FROM
(
SELECT DISTINCT
emp.center ||'emp'|| emp.id AS employee_id,
emp.passwd_expiration AS expiration_date,
p.fullname,
--STRING_AGG(r.rolename, ';') AS role_action,
r.rolename AS action,
r.is_action,
--STRING_AGG(roac.rolename, ';') AS role_action,
roac.rolename AS role_action,
roac.is_action AS roac_isaction,
emp.last_login
FROM
persons p
JOIN
employees emp
ON
emp.personcenter = p.center
AND emp.personid = p.id
JOIN
sats.employeesroles empr
ON
empr.center = emp.center
AND empr.id = emp.id
LEFT JOIN
roles r
ON
r.id = empr.roleid
AND r.blocked = false
LEFT JOIN
impliedemployeeroles iempr
ON
iempr.roleid = r.id
LEFT JOIN
roles roac
ON
roac.id = iempr.implied
WHERE
(r.id IN (:actions) OR roac.id IN (:actions))
--AND emp.blocked = false
AND emp.last_login >= '2023-01-01'
AND p.fullname NOT LIKE 'Exerp Support%'
AND p.fullname NOT LIKE 'EXERP SUPPORT%'
AND p.fullname NOT LIKE 'EXERP STAFF%'
AND p.center IN (:scope)
AND p.persontype = 2
--AND p.status NOT IN (4,5,7,8)
 ) t
ORDER BY
t.employee_id