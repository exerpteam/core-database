SELECT
p.center ||'p'|| p.id AS "PersonId",
p.firstname,
p.lastname,
CASE P.PERSONTYPE 
	WHEN 0 THEN 'PRIVATE'
	WHEN 1 THEN 'STUDENT' 
	WHEN 2 THEN 'STAFF'
	WHEN 3 THEN 'FRIEND'
	WHEN 4 THEN 'CORPORATE'
	WHEN 5 THEN 'ONE MAN CORPORATE'
	WHEN 6 THEN 'FAMILY'
	WHEN 7 THEN 'SENIOR'
	WHEN 8 THEN 'GUEST' 
	ELSE 'UNKNOWN' END AS PERSONTYPE,
CASE P.STATUS 
	WHEN 0 THEN 'LEAD' 
	WHEN 1 THEN 'ACTIVE' 
	WHEN 2 THEN 'INACTIVE'
	WHEN 3 THEN 'TEMPORARY INACTIVE' 
	WHEN 4 THEN 'TRANSFERRED'
	WHEN 5 THEN 'DUPLICATE' 
        WHEN 6 THEN 'PROSPECT'
	WHEN 7 THEN 'DELETED'
	WHEN 8 THEN 'ANONIMIZED'
	WHEN 9 THEN 'CONTACT'
	ELSE 'UNKNOWN' END AS STATUS,
c.name as "center",
pclsp.new_value AS Employee_ID,
e.center ||'emp'|| e.id AS "username",
(TO_CHAR(longtodateC(e.created_at,p.center),'YYYY-MM-DD')) AS "Created_at",
e.last_login,
er.roleid,
r.rolename,
r.blocked AS "role_is_blocked",
r.is_action,
        CASE
                WHEN er.scope_type = 'G' AND er.scope_id = 0 THEN 'System'
                WHEN er.scope_type = 'C' THEN cc.shortname 
                WHEN er.scope_type = 'T' AND er.scope_id = 1 THEN 'Global'
                WHEN er.scope_type = 'A' THEN a.name
                ELSE 'To be mapped'
        END AS scope
--cc.name as "Scope_center",
--a.name as "Scope_area"

FROM	
employees e
JOIN persons p
ON p.id = e.personid AND p.center = e.personcenter
JOIN centers c
ON c.id = e.center
JOIN employeesroles er
ON er.id = e.id AND er.center = e.center
JOIN roles r
ON r.id = er.roleid
LEFT JOIN
        centers cc
        ON cc.id = er.scope_id
        AND er.scope_type = 'C' 
LEFT JOIN
        areas a
        ON a.id = er.scope_id
LEFT JOIN
            person_change_logs pclsp
        ON pclsp.person_center = p.center
        AND pclsp.person_id = p.id
        AND pclsp.CHANGE_ATTRIBUTE = '_eClub_StaffExternalId'    
WHERE status NOT IN (2,5,7,8)
AND e.Blocked Is FALSE
AND e.center in (:Scope)
AND r.blocked = true