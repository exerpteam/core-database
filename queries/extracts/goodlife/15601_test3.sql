SELECT 
	ar.customercenter || 'p' || ar.customerid AS PersonID,
	p.fullname,
	par.center || 'par' || par.id || 'par' || par.subid AS PaymentAgreementID,
	(CASE WHEN par.state = 1 THEN 'Created'
	WHEN par.state = 1 THEN 'Created'
	WHEN par.state = 2 THEN 'Sent'
	WHEN par.state = 3 THEN 'Failed'
	WHEN par.state = 4 THEN 'OK'
	WHEN par.state = 5 THEN 'Ended by Bank'
	WHEN par.state = 6 THEN 'Ended by Clearing House'
	WHEN par.state = 7 THEN 'Ended by Debtor'
	WHEN par.state = 8 THEN 'Cancelled'
	WHEN par.state = 10 THEN 'Ended by Creditor'
	WHEN par.state = 14 THEN 'Incomplete'
	WHEN par.state = 16 THEN 'Changed/Recreated'
	ELSE 'Unknown' END)AS PaymentAgreementStatus,
	CASE WHEN par.payment_cycle_config_id = 1
	THEN 'Bi-weekly'
	ELSE 'Monthly' END AS PaymentCycle,
	(CASE WHEN par.payment_cycle_config_id = 1
	AND par.individual_deduction_day = 1
    THEN 'Monday (Even Weeks)'
	WHEN par.payment_cycle_config_id = 1    
	AND par.individual_deduction_day = 2
	THEN 'Tuesday (Even Weeks)'
    WHEN par.payment_cycle_config_id = 1
	AND par.individual_deduction_day = 3
    THEN 'Wednesday (Even Weeks)'
	WHEN par.payment_cycle_config_id = 1
    AND par.individual_deduction_day = 4
    THEN 'Thursday (Even Weeks)'
    WHEN par.payment_cycle_config_id = 1
	AND par.individual_deduction_day = 5
    THEN 'Friday (Even Weeks)'
    WHEN par.payment_cycle_config_id = 1
	AND par.individual_deduction_day = 8
    THEN 'Monday (Odd Weeks)'
	WHEN par.payment_cycle_config_id = 1    
	AND par.individual_deduction_day = 9
	THEN 'Tuesday (Odd Weeks)'
    WHEN par.payment_cycle_config_id = 1
	AND par.individual_deduction_day = 10
    THEN 'Wednesday (Odd Weeks)'
	WHEN par.payment_cycle_config_id = 1
    AND par.individual_deduction_day = 11
    THEN 'Thursday (Odd Weeks)'
    WHEN par.payment_cycle_config_id = 1
	AND par.individual_deduction_day = 12
    THEN 'Friday (Odd Weeks)'

	WHEN par.payment_cycle_config_id = 201
	AND par.individual_deduction_day = 1
    THEN 'Monday (Even Weeks)'
	WHEN par.payment_cycle_config_id = 201    
	AND par.individual_deduction_day = 2
	THEN 'Tuesday (Even Weeks)'
    WHEN par.payment_cycle_config_id = 201
	AND par.individual_deduction_day = 3
    THEN 'Wednesday (Even Weeks)'
	WHEN par.payment_cycle_config_id = 201
    AND par.individual_deduction_day = 4
    THEN 'Thursday (Even Weeks)'
    WHEN par.payment_cycle_config_id = 201
	AND par.individual_deduction_day = 5
    THEN 'Friday (Even Weeks)'
    WHEN par.payment_cycle_config_id = 201
	AND par.individual_deduction_day = 8
    THEN 'Monday (Odd Weeks)'
	WHEN par.payment_cycle_config_id = 201    
	AND par.individual_deduction_day = 9
	THEN 'Tuesday (Odd Weeks)'
    WHEN par.payment_cycle_config_id = 201
	AND par.individual_deduction_day = 10
    THEN 'Wednesday (Odd Weeks)'
	WHEN par.payment_cycle_config_id = 201
    AND par.individual_deduction_day = 11
    THEN 'Thursday (Odd Weeks)'
    WHEN par.payment_cycle_config_id = 201
	AND par.individual_deduction_day = 12
    THEN 'Friday (Odd Weeks)'

    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 1
    THEN '1st'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 2
    THEN '2nd'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 3
    THEN '3rd'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 4
    THEN '4th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 5
    THEN '5th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 6
    THEN '6th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 7
    THEN '7th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 8
    THEN '8th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 9
    THEN '9th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 10
    THEN '10th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 11
    THEN '11th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 12
    THEN '12th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 13
    THEN '13th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 14
    THEN '14th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 15
    THEN '15th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 16
    THEN '16th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 17
    THEN '17th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 18
    THEN '18th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 19
    THEN '19th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 20
    THEN '20th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 21
    THEN '21st'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 22
    THEN '22nd'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 23
    THEN '23rd'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 24
    THEN '24th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 25
    THEN '25th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 26
    THEN '26th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 27
    THEN '27th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 28
    THEN '28th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 29
    THEN '29th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 30
    THEN '30th'
    WHEN par.payment_cycle_config_id = 2
	AND par.individual_deduction_day = 31
    THEN '31st'

	WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 1
    THEN '1st'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 2
    THEN '2nd'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 3
    THEN '3rd'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 4
    THEN '4th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 5
    THEN '5th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 6
    THEN '6th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 7
    THEN '7th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 8
    THEN '8th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 9
    THEN '9th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 10
    THEN '10th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 11
    THEN '11th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 12
    THEN '12th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 13
    THEN '13th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 14
    THEN '14th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 15
    THEN '15th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 16
    THEN '16th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 17
    THEN '17th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 18
    THEN '18th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 19
    THEN '19th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 20
    THEN '20th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 21
    THEN '21st'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 22
    THEN '22nd'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 23
    THEN '23rd'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 24
    THEN '24th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 25
    THEN '25th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 26
    THEN '26th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 27
    THEN '27th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 28
    THEN '28th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 29
    THEN '29th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 30
    THEN '30th'
    WHEN par.payment_cycle_config_id = 202
	AND par.individual_deduction_day = 31
    THEN '31st'

	ELSE 'Unknown' END) AS DeductionDay,
	par.ended_reason_text,
	par.ended_date,
	par.ended_clearing_in AS EndedInvoiceID,
	ar.balance as AccountBalance,
to_char(longtodatec(ar.last_trans_time, ar.center),'YYYY-MM-DD') AS LastTransactionDate

, acl.*

FROM ACCOUNT_RECEIVABLES ar

JOIN PAYMENT_AGREEMENTS par

ON
	ar.center = par.center
AND
	ar.id = par.id
JOIN 
	PERSONS p
ON
	ar.customercenter = p.center
AND 
	ar.customerid = p.id

JOIN agreement_change_log acl
	On acl.agreement_center = par.center
	AND acl.agreement_id = par.id
	AND acl.agreement_subid = par.subid

WHERE
	ar.ar_type = '4'
AND
	ar.customercenter || 'p' || ar.customerid IN ($$PersonID$$)