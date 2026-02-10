-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	Pr.REQ_DATE,
    ar.CUSTOMERCENTER ||'p'|| ar.CUSTOMERID person,
    pr.REQ_AMOUNT,
    pr.REF,
    pr.FULL_REFERENCE 
FROM
    PAYMENT_REQUESTS pr
JOIN
    ACCOUNT_RECEIVABLES ar
JOIN
    PERSONS p
	ON ar.CUSTOMERCENTER = p.CENTER
		AND ar.CUSTOMERID = p.ID
	ON ar.CENTER = pr.CENTER
		AND ar.ID = pr.ID
WHERE	
	pr.REQ_AMOUNT > 0
AND
	PR.creditor_ID = 'DD LAU SEPA'
AND
	pr.REQ_DATE = $$PaymentDate$$
AND	
	p.sex <> 'C'
	