-- The extract is extracted from Exerp on 2026-02-08
-- To support club openings and closings due to COVID-19, PDS needs to audit and resolve instances where the person club is different from the main subscription club. When the person and the subscription are not at the same club, this can cause issues with billing and revenue.

The new “Person and Subscription Club Mismatch” extract will provide a list to PDS so they can transfer persons to the subscription club to resolve the above issues.
SELECT 
	CONCAT(p.center,'p',p.id) as ClubPersonID,
	CASE p.persontype
		WHEN 0 THEN 'PRIVATE'
		WHEN 1 THEN 'STUDENT' 
		WHEN 2 THEN 'STAFF' 
		WHEN 3 THEN 'FRIEND' 
		WHEN 4 THEN 'CORPORATE' 
		WHEN 5 THEN 'ONE MAN CORPORATE' 
		WHEN 6 THEN 'FAMILY' 
		WHEN 7 THEN 'SENIOR' 
		WHEN 8 THEN 'GUEST' 
		WHEN 10 THEN 'EXTERNAL STAFF' 
		ELSE 'UNKNOWN' 
	END AS Person_Type,
	CONCAT(s.center,'ss',s.id) as SubscriptionID,
	CASE S.STATE 
		WHEN 2 THEN 'ACTIVE' 
		WHEN 3 THEN 'ENDED' 
		WHEN 4 THEN 'FROZEN' 
		WHEN 7 THEN 'WINDOW' 
		WHEN 8 THEN 'CREATED' 
		ELSE 'UNKNOWN' 
	END AS STATE, 
	CASE S.SUB_STATE 
		WHEN 1 THEN 'NONE' 
		WHEN 2 THEN 'AWAITING ACTIVATION' 
		WHEN 3 THEN 'UPGRADED' 
		WHEN 4 THEN 'DOWNGRADED' 
		WHEN 5 THEN 'EXTENDED' 
		WHEN 6 THEN 'TRANSFERRED' 
		WHEN 7 THEN 'REGRETTED' 
		WHEN 8 THEN 'CANCELLED' 
		WHEN 9 THEN 'BLOCKED' 
		WHEN 10 THEN 'CHANGED' 
		ELSE 'UNKNOWN' 
	END AS SUBSTATE,
	s.center as SubscriptionCenter,
	subc.name as CenterName,
	s.owner_center as MemberCenter,
	perc.name as MemberCenterName,
	p.city as MemberAddressCity,
	s.start_date,
	s.end_date,
	s.billed_until_date,
	pr.name as SubscriptionName,
	rperson.external_id AS "Payer_ExternalID",
	TO_CHAR(longtodatec(scl.book_start_time, p.center),'YYYY-MM-DD HH24:MI') AS "RELATION_FROM_DATE",
	TO_CHAR(longtodatec(scl.book_end_time, p.center),'YYYY-MM-DD HH24:MI') AS "RELATION_TO_DATE"
 
FROM subscriptions s

JOIN persons p 
	ON p.center = s.owner_center 
	AND p.id = s.owner_id

JOIN products pr 
	ON pr.center = s.subscriptiontype_center 
	AND pr.id = s.subscriptiontype_id

JOIN product_and_product_group_link ppg
	ON s.subscriptiontype_center = ppg.product_center 
	AND s.subscriptiontype_id = ppg.product_id

JOIN centers perc -- person center
	ON s.owner_center = perc.id

JOIN centers subc -- subscription center
	ON s.center = subc.id

LEFT JOIN relatives rel
	ON p.center = rel.relativecenter 
	AND p.id = rel.relativeid
	AND rel.status = 1 -- active relation
	AND rel.rtype = 12 -- my payer relation type

LEFT JOIN state_change_log scl
	ON rel.center = scl.center
	AND rel.id = scl.id
	AND rel.subid = scl.subid
	AND scl.stateid = 1
	AND scl.entry_type = 4

LEFT JOIN persons rperson
	ON rel.center = rperson.center 
	AND rel.id = rperson.id

WHERE s.state <> 3 -- NOT Cancelled
	AND ppg.product_group_id = 1004 -- "Memberships" Product Group
	AND s.center <> s.owner_center -- person center and subscription center don't match
	AND p.center in ($$scope$$) -- person center in scope selected