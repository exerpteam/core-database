SELECT
	p.center || 'p' || p.id AS PersonID,	
	CASE par.state
        WHEN 14
        THEN 'Incomplete'
        WHEN 3
        THEN 'Failed'
        ELSE 'UNKNOWN'
    END AS "Payment Agreement Status"
FROM PAYMENT_AGREEMENTS par
JOIN PAYMENT_ACCOUNTS pa on 
	pa.ACTIVE_AGR_CENTER = par.CENTER
    AND pa.ACTIVE_AGR_ID = par.ID
    AND pa.ACTIVE_AGR_SUBID = par.SUBID
JOIN ACCOUNT_RECEIVABLES ar ON
    ar.CENTER = pa.CENTER and ar.id = pa.id
JOIN PERSONS p ON 
	p.ID = ar.CUSTOMERID AND
	p.CENTER = ar.CUSTOMERCENTER
WHERE
	par.state IN ('14','3')