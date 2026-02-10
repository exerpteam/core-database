-- The extract is extracted from Exerp on 2026-02-08
-- Created For: Jesse G, Diane C - to help with saved free days clean up
Created by: Sandra G
Date Added: November 2023
WITH subscriptions_list AS (

	SELECT
	
	s.center
	,s.id
	
	FROM
	
	subscriptions s
	
	WHERE
	
	
		(s.center,s.id) IN (:ID)
	

), pay_agr AS (

	-- Hard-Coded Link in Subscriptions Table
	
	SELECT

	s.payment_agreement_center AS center
	,s.payment_agreement_id AS id
	,s.payment_agreement_subid AS subid
	,s.center||'ss'||s.id AS subscription_id

	FROM

	subscriptions s
	
	JOIN subscriptions_list sl USING (center,id)

	WHERE

	s.payment_agreement_center IS NOT NULL

	UNION

	-- Other Payor
	
	SELECT

	pa.active_agr_center AS center
	,pa.active_agr_id AS id
	,pa.active_agr_subid AS subid
	,s.center||'ss'||s.id AS subscription_id

	FROM

	subscriptions s
	
	JOIN subscriptions_list sl USING (center,id)

	JOIN relatives r
	ON s.owner_center = r.relativecenter
	AND s.owner_id = r.relativeid
	AND r.status = 1
	AND r.rtype = 12 
	AND s.payment_agreement_center IS NULL

	JOIN account_receivables ar
	ON ar.customercenter = r.center
	AND ar.customerid = r.id
	AND ar.ar_type = 4

	JOIN payment_accounts pa
	ON pa.center = ar.center
	AND pa.id = ar.id

	UNION

	SELECT

	-- Member paying for own subscription - default payment agreement
	
	pa.active_agr_center AS center
	,pa.active_agr_id AS id
	,pa.active_agr_subid AS subid
	,s.center||'ss'||s.id AS subscription_id

	FROM

	subscriptions s

	JOIN subscriptions_list sl USING (center,id)
	
	JOIN account_receivables ar
	ON ar.customercenter = s.owner_center
	AND ar.customerid = s.owner_id
	AND ar.ar_type = 4
	AND s.payment_agreement_center IS NULL

	JOIN payment_accounts pa
	ON pa.center = ar.center
	AND pa.id = ar.id

	WHERE

	NOT EXISTS (

		SELECT

		1

		FROM

		relatives r

	  	WHERE  

		s.owner_center = r.relativecenter
		AND s.owner_id = r.relativeid
		AND r.status = 1
		AND r.rtype = 12 

	)
	
)

SELECT

pagr.subscription_id
,pa.individual_deduction_day
,pa.payment_cycle_config_id
,ar.customercenter||'p'||ar.customerid AS Payor_id
,CASE
    WHEN pcc.interval_type = 2 -- Monthly
    THEN CAST(pa.individual_deduction_day AS TEXT)
    WHEN pa.individual_deduction_day IN (1,8) AND pa.payment_cycle_config_id = 1
    THEN TEXT 'Monday'
    WHEN pa.individual_deduction_day IN (2,9) AND pa.payment_cycle_config_id = 1
    THEN TEXT 'Tuesday'
     WHEN pa.individual_deduction_day IN (3,10) AND pa.payment_cycle_config_id = 1
    THEN TEXT 'Wednesday'
     WHEN pa.individual_deduction_day IN (4,11) AND pa.payment_cycle_config_id = 1
    THEN TEXT 'Thursday'
     WHEN pa.individual_deduction_day IN (5,12) AND pa.payment_cycle_config_id = 1
    THEN TEXT 'Friday'
    ELSE ''
END || CASE
    WHEN pa.individual_deduction_day BETWEEN 1 AND 5 AND pcc.interval_type = 0
    THEN TEXT ' (Even Weeks)'
    WHEN pa.individual_deduction_day BETWEEN 8 AND 12 AND pcc.interval_type = 0
    THEN TEXT ' (Odd Weeks)'
    WHEN pa.individual_deduction_day IN (1,21,31) AND pcc.interval_type = 2
    THEN TEXT 'st'
    WHEN pa.individual_deduction_day IN (2,22) AND pcc.interval_type = 2
    THEN TEXT 'nd'
    WHEN pa.individual_deduction_day IN (3,23) AND pcc.interval_type = 2
    THEN TEXT 'rd'
    WHEN pcc.interval_type = 2
    THEN TEXT 'th'
    ELSE ''
END AS Deduction_Day
,CASE
    WHEN pcc.interval_type = 2
    THEN 'Monthly'
    WHEN pcc.interval_type = 0
    THEN 'Bi-Weekly'
    ELSE 'Unknown'
END AS deduction_cycle

FROM

pay_agr pagr

JOIN payment_agreements pa USING (center,id,subid)

JOIN account_receivables ar USING (center,id)

JOIN payment_cycle_config pcc
ON pa.payment_cycle_config_id = pcc.id

