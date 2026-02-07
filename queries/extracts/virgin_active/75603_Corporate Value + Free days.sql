SELECT distinct
    p.center ||'p'|| p.id as personid, 
    p.center as center,
	  CASE  p.persontype  
		WHEN 0 THEN 'Private'  
		WHEN 1 THEN 'Student'  
		WHEN 2 THEN 'Staff'  
		WHEN 3 THEN 'Friend'  
		WHEN 4 THEN 'Corporate'  
		WHEN 5 THEN 'Onemancorporate'  
		WHEN 6 THEN 'Family'  
		WHEN 7 THEN 'Senior'  
		WHEN 8 THEN 'Guest'  
		WHEN 9 THEN  'Child'  
		WHEN 10 THEN  'External_Staff' 
		ELSE 'Unknown' END AS person_type,
	prod.name as subscription_name,
	s.subscription_price "Subscription price",
 	/* CASE
		WHEN TRUNC(months_between(S.end_DATE,s.start_DATE)) < 1 THEN s.subscription_price
		WHEN s.end_date IS NULL THEN s.subscription_price
		ELSE ROUND ((s.subscription_price/ TRUNC(months_between(S.end_DATE,s.start_DATE))),2)
		END AS "monthly_price", */
	TO_TIMESTAMP(s.creation_time / 1000) as sub_creation_time,
	s.saved_free_days as Saved_Free_Days,
	srp.start_date as Free_period_start_date,
	srp.end_date as Free_period_end_date,
	TO_TIMESTAMP(srp.entry_time / 1000) as Inserimento_Free_Period, 
	srp.text as comment,
	pea.txtvalue AS corporate_value
FROM
	SUBSCRIPTIONS s
JOIN
	PERSONS p
ON
	p.CENTER = s.OWNER_CENTER
	AND p.ID = s.OWNER_ID
join 
	centers c
on 
	c.id = p.center
and 
	c.country = 'IT'
JOIN 
	subscriptiontypes st
ON 
	st.center = s.subscriptiontype_center
AND 
	st.id = s.subscriptiontype_id
JOIN 
	products prod
ON 
	prod.center = s.subscriptiontype_center
AND 
	prod.id = s.subscriptiontype_id
LEFT JOIN PERSON_EXT_ATTRS pea
ON pea.PERSONCENTER = p.CENTER AND pea.PERSONID = p.ID 
AND pea.NAME = 'Corporatevalue'
LEFT JOIN subscription_reduced_period srp
ON s.center = srp.subscription_center
AND s.id=srp.subscription_id
AND srp.type in ('FREE_ASSIGNMENT', 'SAVED_FREE_DAYS_USE')
and srp.end_date >= CURRENT_DATE 
WHERE
p.center in (:scope)
and s.state in (:Subscription_state)
and prod.ptype = 10
AND prod.BLOCKED = 0
AND p.persontype IN (0, 1, 3, 4, 5, 6, 7, 8, 9)
--and pea.txtvalue is not null