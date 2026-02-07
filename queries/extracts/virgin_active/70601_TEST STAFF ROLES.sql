 WITH eligible AS
 (
         SELECT
                 p.center,
                 p.id,
                 p.status,
                 p.external_id,
				 p.fullname,
				 p.friends_allowance,
				 p.ssn,

				 e.center AS empCenter,
                 e.id AS empId
         FROM PERSONS p
         JOIN CENTERS c ON p.CENTER = c.ID AND c.COUNTRY = 'IT'
         JOIN EMPLOYEES e ON p.CENTER = e.PERSONCENTER AND p.ID = e.PERSONID AND e.BLOCKED = 0
         WHERE
                 p.PERSONTYPE = 2
                 AND p.STATUS IN (0,1,2,3,6,9)
                 
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
				 t2.fullname,
				 t2.friends_allowance,

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
                                 WHEN er.scope_type IN ('A','C','G','T') THEN r.rolename || ' (' || a.name || ')'
                                 ELSE NULL
                         END) ScopesRoles
                 FROM
                         eligible
                 JOIN EMPLOYEESROLES er ON er.center = eligible.empCenter AND er.ID = eligible.empId
                 JOIN ROLES r ON er.ROLEID = r.id
                 LEFT JOIN CENTERS c ON c.ID = er.SCOPE_ID AND er.SCOPE_TYPE = 'A' AND er.SCOPE_TYPE = 'C' AND er.SCOPE_TYPE = 'G' AND er.SCOPE_TYPE = 'T'
                 LEFT JOIN AREAS a ON a.ID = er.SCOPE_ID AND er.SCOPE_TYPE IN ('A','C','G','T')
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
				 t2.fullname,
				 t2.friends_allowance,
                 t2.status
 ) t1
 ON eligible.empCenter = t1.empCenter
 AND eligible.empId = t1.empId