 SELECT
         c.id as ClubId
         , c.SHORTNAME as ClubName
         , concat(concat(cast(p.center as varchar(4)),'p'),cast(e.PERSONID as varchar(6))) as PersonId
         , CONCAT(CONCAT(CAST(e.CENTER AS CHAR(3)),'emp'),CAST(e.ID as VARCHAR(6))) as EmployeeId
         , CONCAT(CONCAT(p.FIRST_NAME, ' '), p.LAST_NAME) as Name
         , ROLENAME as Role
 FROM
         EMPLOYEES e
 INNER JOIN
         PERSONS_VW p ON e.PERSONCENTER = p.CENTER AND e.PERSONID = p.ID
 INNER JOIN
         CENTERS c ON c.ID = p.CENTER
 INNER JOIN
         EMPLOYEESROLES er on er.ID = e.ID AND er.CENTER = e.CENTER
 INNER JOIN
         ROLES r ON r.ID = er.ROLEID
 INNER JOIN
         CENTERS c2 ON c2.ID = e.CENTER
 WHERE
         e.BLOCKED = 0
         AND
         p.STATUS = 'ACTIVE'
         AND
         c.COUNTRY = 'IT'
         AND
         IS_ACTION = 0
 GROUP BY
         c.id
         , c.SHORTNAME
         , CONCAT(CONCAT(p.FIRST_NAME, ' '), p.LAST_NAME)
         , CONCAT(CONCAT(CAST(e.CENTER AS CHAR(3)),'emp'),CAST(e.ID as VARCHAR(6)))
         , ROLENAME,concat(concat(cast(p.center as varchar(4)),'p')
         , cast(e.PERSONID as varchar(6)))
 ORDER BY
         c.SHORTNAME
         , CONCAT(CONCAT(p.FIRST_NAME, ' '), p.LAST_NAME)
