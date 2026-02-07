SELECT
         C.ID,
         C.NAME,
     emp.CENTER || 'emp' || emp.id "Employee Logon",
     (CASE p.STATUS
        WHEN 1 THEN 'ACTIVE'    
    END) AS person_STATUS,
     p.CENTER || 'p' || p.ID member_id,
     p.FULLNAME,
     r.IS_ACTION,
     r.ROLENAME,
     empr.SCOPE_TYPE,
     empr.SCOPE_ID,
	 emp.passwd_expiration,
	 emp.passwd_never_expires,
	 emp.last_login



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
     r.IS_ACTION,
     r.ROLENAME
