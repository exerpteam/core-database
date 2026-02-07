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
	cr.AMOUNT AS Kostnad
FROM CASHREGISTERTRANSACTIONS cr
JOIN PERSONS p
	ON cr.CUSTOMERCENTER = p.CENTER
	AND cr.CUSTOMERID = p.ID
WHERE 
	cr.CUSTOMERCENTER=(:center)and 
	cr.CRTTYPE = 13 and -- This is type = Other
	cr.CENTER in (:center)
	AND cr.TRANSTIME >= :FromDate
   	AND cr.TRANSTIME < :ToDate + (1000*60*60*24)
