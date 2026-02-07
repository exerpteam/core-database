SELECT
	emp.PERSONCENTER || 'p' || emp.PERSONID AS PId,
	emp.PERSONCENTER,
	emp.PERSONID,
	CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END PERSONTYPE, 
    CASE  per.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' ELSE 'UNKNOWN' END PERSONSTATUS,
	per.FIRSTNAME,
	per.LASTNAME,
    pea_email.txtvalue            			AS Email,
	pea_mobile.txtvalue						AS PhoneMobile,
	emp.CENTER || 'emp' || emp.ID 			AS EmpId,
	emp.LAST_LOGIN,
	emp.BLOCKED,
	r.ID 									AS Role_Id,
	r.ROLENAME,
	pea_department.txtvalue				AS Department,
	er.SCOPE_ID,
	centers.Name AS RoleScopeName

	
	
FROM
	EMPLOYEES emp

LEFT JOIN PERSONS per
ON
	emp.PERSONCENTER = per.CENTER
	AND emp.PERSONID = per.ID
LEFT JOIN PERSON_EXT_ATTRS pea_email
ON
    pea_email.PERSONCENTER = per.center
AND pea_email.PERSONID = per.id
AND pea_email.NAME = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = per.center
	AND pea_mobile.PERSONID = per.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'
LEFT JOIN PERSON_EXT_ATTRS pea_department
ON
    pea_department.PERSONCENTER = per.center
	AND pea_department.PERSONID = per.id
	AND pea_department.NAME = '_eClub_StaffExternalId'
JOIN EMPLOYEESROLES er
ON
	emp.CENTER = er.CENTER
	AND emp.ID = er.ID
	AND er.ROLEID IN (8171, 8173, 8175, 8176, 8177, 8178, 8180, 8181, 8183, 8174, 8179, 8182, 8607, 10059, 10060)
Left Join Centers
On
er.SCOPE_ID = Centers.ID

LEFT JOIN ROLES r
ON
	er.ROLEID = r.ID
--	AND r.ID IN (8171, 8173, 8175, 8176, 8177, 8178, 8180, 8181, 8183, 8174, 8179, 8182, 8607, 10059, 10060)
