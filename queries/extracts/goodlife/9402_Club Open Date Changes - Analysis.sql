SELECT
	p.external_ID AS CustomerExternalID,
	p.fullname AS CustomerName,
	ep.external_ID AS EmployeeExternalID,
	ep.fullname AS EmployeeName,
	longtodate (at.trans_time) AS TransactionDate,
	at.*
FROM 
	AR_TRANS at
JOIN
	ACCOUNT_RECEIVABLES ar 
ON
	at.ID = ar.ID AND
	at.CENTER = ar.CENTER
JOIN
	PERSONS p
ON
	p.ID = ar.CUSTOMERID AND
	p.CENTER = ar.CUSTOMERCENTER
JOIN
	PERSONS ep
ON
	at.employeecenter = ep.center
AND
	at.employeeid = ep.id
WHERE
	at.center = '317'
AND
	longtodate (at.trans_time) > '2017-08-28'