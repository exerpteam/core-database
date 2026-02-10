-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT pa.personCenter, pa.personId, pa1.REF
FROM (
SELECT p.CENTER as personCenter, p.ID as personId, pa.CENTER, pa.ID
   FROM PERSONS p

LEFT JOIN 
	ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.ID
    AND ar.AR_TYPE = 4
LEFT 
	JOIN PAYMENT_ACCOUNTS pac
ON
    pac.CENTER = ar.CENTER
    AND pac.ID = ar.ID
LEFT JOIN 
	PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.ID = pac.ACTIVE_AGR_ID
	AND pa.SUBID = pac.ACTIVE_AGR_SUBID

WHERE p.CENTER  IN (select c.ID from CENTERS c where  c.COUNTRY = 'IT' )) pa
INNER JOIN PAYMENT_AGREEMENTS pa1
ON
pa.CENTER = pa1.CENTER
AND
pa.ID = pa1.ID
WHERE pa1.CLEARINGHOUSE = 803
ORDER BY pa.personCenter, pa.personid
