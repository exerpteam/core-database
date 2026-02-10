-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
         C.ID,
         C.NAME,
     emp.CENTER || 'emp' || emp.id "Employee Logon",
     (CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
		WHEN 10 THEN 'BLOCKED'
        ELSE 'UNKNOWN'
    END) AS person_STATUS,
     p.CENTER || 'p' || p.ID member_id,
	 p.external_id,
     p.FULLNAME,
     r.IS_ACTION,
     empr.SCOPE_TYPE,
     empr.SCOPE_ID
	 



 FROM
     EMPLOYEES emp
 JOIN
         PERSONS p
         ON p.CENTER = emp.PERSONCENTER
     AND p.ID = emp.PERSONID
 JOIN
         EMPLOYEESROLES empr
         ON empr.CENTER = emp.CENTER
     AND empr.id = emp.ID
 JOIN
         ROLES r
         ON r.ID = empr.ROLEID
 JOIN
         CENTERS c
         ON c.id = p.CENTER
 WHERE
     
     emp.center in (:scope)
 ORDER BY
     c.NAME,
     emp.CENTER,
     p.FULLNAME,
     r.IS_ACTION