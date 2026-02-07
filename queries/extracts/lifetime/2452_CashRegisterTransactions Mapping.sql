SELECT
	p.fullname,
	TO_CHAR(longtodateC(c.transtime, c.center), 'YYYY-MM-DD HH24:MI:SS') AS TransTime,
	c.crttype, 
	c.*
FROM 
	CashRegisterTransactions c
JOIN
	Persons p
ON
	c.customercenter = p.center
AND
	c.customerid = p.id

WHERE
	c.center = '990'
AND
	TO_CHAR(longtodateC(c.transtime, c.center), 'YYYY-MM-DD') = '2017-12-04'

LIMIT 1000