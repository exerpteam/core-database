-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
p.firstname,
p.lastname,
p.external_id,
c.name as "center",
e.center ||'emp'|| e.id AS "username",
e.last_login

FROM

    employees e
JOIN persons p
ON p.id = e.personid AND p.center = e.personcenter
JOIN centers c
ON c.id = e.center
where e.center in (:scope)