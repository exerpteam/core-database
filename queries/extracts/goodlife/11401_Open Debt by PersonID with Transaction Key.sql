SELECT
	p.center || 'p' || p.id as PersonID,
	p.firstname,
    p.lastname,
	a.name AS GlobalAccount, 
	a.external_id,
	art.center || 'ar' || art.id || 'art' || art.subid AS TransactionKey,
	LONGTODATE (art.trans_time) AS TransactionDate,
	art.amount,
	art.due_date, 
	art.info,
	art.text,
	art.ref_type,
	art.status,
	art.unsettled_amount,
	art.collected_amount
FROM 
	AR_TRANS art
JOIN
	ACCOUNT_RECEIVABLES ar 
ON
	art.center = ar.center
AND
	art.id = ar.id
AND 
	ar.ar_type != 1
AND 
	art.status != 'CLOSED'
JOIN 
	PERSONS p
ON
	ar.CUSTOMERID = p.ID AND
	ar.CUSTOMERCENTER = p.CENTER
LEFT JOIN 
	ACCOUNT_TRANS at
ON
	at.center = art.ref_center
AND
	at.id = art.ref_id
AND
	at.subid = art.ref_subid
LEFT JOIN
	ACCOUNTS a
ON
	a.center = at.credit_accountcenter
AND
	a.id = at.credit_accountid

WHERE
	p.center || 'p' || p.id IN ($$personid$$)