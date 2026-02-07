select concat(concat(cast(p1.center as char(3)), 'p'), cast(p1.id as varchar(10)))  as personId, agr.BANK_ACCNO, agr.EXAMPLE_REFERENCE, agr.EXPIRATION_DATE 
FROM 

	PERSONS p1
INNER JOIN CENTERS C
on p1.center = c.id

INNER JOIN 
ACCOUNT_RECEIVABLES ar
on
 ar.CUSTOMERCENTER = p1.CENTER
    AND ar.CUSTOMERID = p1.ID
AND ar.AR_TYPE = 4

INNER JOIN 
	PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
	
INNER  JOIN PAYMENT_AGREEMENTS agr
ON agr.CENTER = pac.ACTIVE_AGR_CENTER
AND agr.ID = pac.ACTIVE_AGR_ID


where
--EXAMPLE_REFERENCE = '30839206'
c.country = 'IT'
-- AND (agr.EXPIRATION_DATE IS NULL OR agr.EXPIRATION_DATE > TO_DATE('30/09/2016','dd/mm/YYYY')) 
--AND ROWNUM <= 30
order by  p1.id, p1.center, agr.BANK_ACCNO