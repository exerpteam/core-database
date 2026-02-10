-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	CASE WHEN p.Id IS NULL
	THEN ''
	ELSE 
		p.center || 'p' || p.id
	END AS PersonId,
	par.*, 
	pa.id,
	ar.id
FROM PAYMENT_AGREEMENTS par
LEFT JOIN PAYMENT_ACCOUNTS pa on 
	pa.ACTIVE_AGR_CENTER = par.CENTER
    AND pa.ACTIVE_AGR_ID = par.ID
    AND pa.ACTIVE_AGR_SUBID = par.SUBID
LEFT JOIN ACCOUNT_RECEIVABLES ar ON
    ar.CENTER = pa.CENTER and ar.id = pa.id
LEFT JOIN PERSONS p ON 
	p.ID = ar.CUSTOMERID AND
	p.CENTER = ar.CUSTOMERCENTER