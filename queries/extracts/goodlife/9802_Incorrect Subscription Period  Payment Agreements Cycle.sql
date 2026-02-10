-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	p.center || 'p' || p.id AS PersonID,
	p.external_id as ExternalID,
	p.fullname,
	pcc.name AS PaymentCycleName,
	--s.state,
	--st.periodcount,
	--pcc.id,
	pr.name AS ProductName,
	s.center AS SubscriptionCenter,
	s.id As SubscriptionID
FROM
	Subscriptions s
	JOIN
	Persons p
		ON
		s.owner_center = p.center
		AND
		s.owner_id = p.id
	JOIN
	Subscriptiontypes st
		ON
		st.center = s.subscriptiontype_center
		AND
		st.id = s.subscriptiontype_id
	JOIN Products pr
		ON pr.center = st.productnew_center
		AND pr.id = st.productnew_id
		
	JOIN
	Payment_agreements pa
		ON
		s.payment_agreement_center = pa.center
		AND
		s.payment_agreement_id = pa.id
		AND
		s.payment_agreement_subid = pa.subid
	JOIN 
	Payment_cycle_config pcc
		ON
		pcc.id = pa.payment_cycle_config_id
WHERE
	(st.periodcount = 1
	AND
	pcc.id =1)
OR
	(st.periodcount = 2
	AND
	pcc.id =2)