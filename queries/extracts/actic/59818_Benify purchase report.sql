-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Creator: Henrik Håkanson
* Purpose: List transaction made with crttype=13 and paymentmethod. 
* This means Actiway or Epassi. Dates and scope are given as parameters.
* Extract is published as report.
*/
SELECT
	cr.CUSTOMERCENTER || 'p' || cr.CUSTOMERID As MemberId,
	p.FULLNAME As Name,
	p.SSN,
	TO_CHAR(longtodate(cr.TRANSTIME), 'YYYY-MM-DD HH24:MI') AS Tid,
	cr.AMOUNT AS Kostnad


FROM CASHREGISTERTRANSACTIONS cr
JOIN PERSONS p
	ON cr.CUSTOMERCENTER = p.CENTER
	AND cr.CUSTOMERID = p.ID

WHERE 
	cr.CRTTYPE = 13 and -- This is type = Other
	cr.CENTER = 100
	AND cr.CONFIG_PAYMENT_METHOD_ID = :payment_method_id
	AND cr.TRANSTIME >= :FromDate
   	AND cr.TRANSTIME < :ToDate + (1000*60*60*24)


