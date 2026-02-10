-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH eligible AS
 (
         SELECT
                 p.center,
                 p.id,
                 p.status,
                 p.external_id,
                 e.center AS empCenter,
                 e.id AS empId
         FROM PERSONS p
         JOIN CENTERS c ON p.CENTER = c.ID AND c.COUNTRY = 'GB'
         JOIN EMPLOYEES e ON p.CENTER = e.PERSONCENTER AND p.ID = e.PERSONID AND e.BLOCKED = 0
         WHERE
                 p.PERSONTYPE = 2
                 AND p.STATUS IN (0,1,2,3,6,9)
                 AND
                 (
                         e.PASSWD_NEVER_EXPIRES = 1
                         OR
                         e.PASSWD_NEVER_EXPIRES = 0 AND
                                                         (
                                                                 e.PASSWD_EXPIRATION IS NULL
                                                                 OR
                                                                 e.PASSWD_EXPIRATION > current_date
                                                         )
                 )
 )
 SELECT
         t1.*
 FROM
         eligible
 JOIN
 (
         SELECT
                 t2.center,
                 t2.id,
                 t2.empCenter,
                 t2.empId,
                 t2.external_id,
                 (CASE t2.status
                         WHEN 0 THEN 'LEAD'
                         WHEN 1 THEN 'ACTIVE'
                         WHEN 2 THEN 'INACTIVE'
                         WHEN 3 THEN 'TEMPORARYINACTIVE'
                         WHEN 6 THEN 'PROSPECT'
                         WHEN 9 THEN 'CONTACT'
                         ELSE 'UNKNOWN'
                 END) AS status,
                 STRING_AGG(CAST(t2.ScopesRoles AS TEXT), ' ; ') AS roleslist
         FROM
         (
                 SELECT
                         eligible.*,
                         (CASE
                                 WHEN er.scope_type = 'C' THEN r.rolename || ' (' || c.name || ')'
                                 WHEN er.scope_type IN ('A','T') THEN r.rolename || ' (' || a.name || ')'
                                 ELSE NULL
                         END) ScopesRoles
                 FROM
                         eligible
                 JOIN EMPLOYEESROLES er ON er.center = eligible.empCenter AND er.ID = eligible.empId
                 JOIN ROLES r ON er.ROLEID = r.id
                 LEFT JOIN CENTERS c ON c.ID = er.SCOPE_ID AND er.SCOPE_TYPE = 'C'
                 LEFT JOIN AREAS a ON a.ID = er.SCOPE_ID AND er.SCOPE_TYPE IN ('A','T')
                 WHERE
                         r.BLOCKED = 0
                         AND r.IS_ACTION = 0
         ) t2
         GROUP BY
                 t2.center,
                 t2.id,
                 t2.empCenter,
                 t2.empId,
                 t2.external_id,
                 t2.status
 ) t1
 ON eligible.empCenter = t1.empCenter
 AND eligible.empId = t1.empId
