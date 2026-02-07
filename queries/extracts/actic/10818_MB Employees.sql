SELECT
	emp.PERSONCENTER || 'p' || emp.PERSONID AS PId,
	emp.PERSONCENTER,
	emp.PERSONID,
	per.EXTERNAL_ID,
	per.FIRSTNAME,
	per.LASTNAME,
	per.fullname,
	emp.CENTER || 'emp' || emp.ID AS EmpId,
	emp.LAST_LOGIN,
	emp.BLOCKED
/*,
	r.ID AS Role_Id,
	r.ROLENAME*/
	
	
FROM
	EMPLOYEES emp

LEFT JOIN PERSONS per
ON
	emp.PERSONCENTER = per.CENTER
	AND emp.PERSONID = per.ID
/*LEFT JOIN EMPLOYEESROLES er
ON
	emp.CENTER = er.CENTER
	AND emp.ID = er.ID

LEFT JOIN ROLES r
ON
	er.ROLEID = r.ID
	*/
WHERE
	emp.CENTER IN (:Scope)
	AND emp.BLOCKED = 0

