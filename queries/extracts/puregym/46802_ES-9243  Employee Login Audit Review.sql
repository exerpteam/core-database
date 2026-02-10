-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
         p.CENTER || 'p' || p.ID AS "Person ID",
         e.CENTER || 'emp' || e.ID AS "Employee Login",
         e.LAST_LOGIN AS "Last Login",
         e.PASSWD_EXPIRATION AS "Password Expiration Date",
         Case e.PASSWD_NEVER_EXPIRES  When 1 Then  'true' When 0 Then  'false' End AS "Password Never Expires"
 FROM
         PERSONS p
 JOIN
         EMPLOYEES e
 ON
         p.CENTER = e.PERSONCENTER
         AND p.ID = e.PERSONID
 WHERE
         p.PERSONTYPE = 2
         AND e.BLOCKED = 0
