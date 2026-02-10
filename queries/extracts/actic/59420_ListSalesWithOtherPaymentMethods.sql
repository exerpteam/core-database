-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Creator: Henrik Håkanson
* ServiceTicket: N/A Request from Club Färjestad
* Purpose: List transaction made with crttype=13. 
* This means Actiway or Epassi. Dates and scope are given as parameters.
* Extract is published as report.
*/
SELECT
	cr.CUSTOMERCENTER || 'p' || cr.CUSTOMERID As MemberId,
	cr.CUSTOMERCENTER AS CENTER,
	p.FULLNAME As Name,
	TO_CHAR(longtodate(cr.TRANSTIME), 'YYYY-MM-DD HH24:MI') AS Tid,
	cr.AMOUNT AS Kostnad,
	CASE
		WHEN cr.CONFIG_PAYMENT_METHOD_ID = 10 THEN 'E-PASSI'
		WHEN cr.CONFIG_PAYMENT_METHOD_ID = 7 THEN 'PAYMENT_LINK'
		ELSE
			CAST(cr.CONFIG_PAYMENT_METHOD_ID AS TEXT)
	END AS PAYMENT_METHOD,
	cr.EMPLOYEECENTER || 'emp' ||cr.EMPLOYEEID AS EmployeeId,
	empPerson.FULLNAME AS EmployeeName
FROM CASHREGISTERTRANSACTIONS cr
JOIN PERSONS p
	ON cr.CUSTOMERCENTER = p.CENTER
	AND cr.CUSTOMERID = p.ID
JOIN EMPLOYEES emp ON
	cr.EMPLOYEECENTER = emp.CENTER
	AND cr.EMPLOYEEID = emp.ID
JOIN PERSONS empPerson ON
	emp.PERSONCENTER = empPerson.CENTER
	AND emp.PERSONID = empPerson.ID
	
WHERE 
	cr.CUSTOMERCENTER IN (:scope)
	AND cr.CRTTYPE = 13 -- This is type = Other
	AND cr.CENTER in (:scope)
	AND cr.TRANSTIME >= :FromDate
   	AND cr.TRANSTIME < :ToDate + (1000*60*60*24)

