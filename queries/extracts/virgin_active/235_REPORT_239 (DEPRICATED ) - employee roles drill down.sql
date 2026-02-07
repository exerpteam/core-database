SELECT
    emp.CENTER || 'emp' || emp.id "Employee Logon",
    p.CENTER || 'p' || p.ID member_id,
    p.FULLNAME, 
    r.IS_ACTION,
    r.ROLENAME,
    empr.SCOPE_TYPE,
    empr.SCOPE_ID 
FROM
    EMPLOYEES emp
JOIN PERSONS p
ON
    p.CENTER = emp.PERSONCENTER
    AND p.ID = emp.PERSONID
JOIN EMPLOYEESROLES empr
ON
    empr.CENTER = emp.CENTER
    AND empr.id = emp.ID
JOIN ROLES r
ON
    r.ID = empr.ROLEID
WHERE
    r.BLOCKED = 0
    AND emp.BLOCKED = 0
	and emp.center in (:scope)
ORDER BY
    emp.CENTER,
    emp.ID,
    r.IS_ACTION,
    r.ROLENAME