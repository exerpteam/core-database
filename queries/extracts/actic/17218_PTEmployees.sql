/*
* Is used to export PT-data to web and app.
*/

SELECT
	emp.PERSONCENTER || 'p' || emp.PERSONID AS PId,
	DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') PERSONTYPE, 
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') PERSONSTATUS,
	per.FIRSTNAME,
	per.LASTNAME,
    pea_email.txtvalue            			AS Email,
	pea_mobile.txtvalue						AS PhoneMobile,
	emp.CENTER || 'emp' || emp.ID 			AS EmpId,
	emp.LAST_LOGIN,
	emp.BLOCKED,
	r.ROLENAME,
	centers.Name AS ROLECENTER

	
	
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
	AND er.ROLEID IN (7330,7354)
Left Join Centers
On
er.SCOPE_ID = Centers.ID

LEFT JOIN ROLES r
ON
	er.ROLEID = r.ID
--	AND r.ID IN (7330,7354)

WHERE per.PERSONTYPE = 2