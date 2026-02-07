SELECT
	CASE WHEN p.Id IS NULL THEN '' ELSE p.center || 'p' || p.id	END AS CompanyPersonId,
	p.lastname as CompanyName,
	CASE WHEN par.payment_cycle_config_id = 601 THEN '601 Monthly Corporate Invoice'
		 WHEN par.payment_cycle_config_id = 401	THEN '401 = Monthly Corporate PAP'
	END,
    par.individual_deduction_day AS PaymentSchedule

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
WHERE p.sex='C'





