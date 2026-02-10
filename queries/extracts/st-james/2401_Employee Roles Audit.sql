-- The extract is extracted from Exerp on 2026-02-08
-- 
SELECT
    E.CENTER||'emp'||E.ID AS EMPID,
    P.CENTER||'p'||P.ID   AS PERSONID,
    P.EXTERNAL_ID,
    P.FULLNAME,
    R.ROLENAME
FROM
    employeesroles er
JOIN
    employees e
ON
    er.center = e.center
AND e.id = er.id
JOIN
    roles r
ON
    r.id = er.roleid
JOIN
    PERSONS P
ON
    P.CENTER = E.personcenter
AND P.ID = E.personid
WHERE
    r.is_action = FALSE
    and p.center in ($$scope$$)

order by P.fullname, r.rolename DESC