SELECT 
	longtodate(s.last_modified) AS ModifiedDate,
	s.center AS CenterID,
	s.owner_center || 'p' || s.owner_id AS PersonID,
	p.external_ID AS ExternalID,
	p.fullname AS FullName,
	(CASE 
		WHEN s.sub_state = '3' THEN 'UPGRADE'
		WHEN s.sub_state = '4' THEN 'DOWNGRADE'
		WHEN s.sub_state = '10' THEN 'CHANGE'
	END) AS ChangeType,
	pg.name AS OldProductGroup,
	pr.name AS OldProductName,
	(CASE 
		WHEN s.state = '2' THEN 'ACTIVE'
		WHEN s.state = '3' THEN 'ENDED'
		WHEN s.state = '4' THEN 'FROZEN'
		WHEN s.state = '8' THEN 'CREATED'
		ELSE 'UNKNOWN'
	END) AS OldProductState,
	(CASE 
		WHEN s.sub_state = '1' THEN 'NONE'
		WHEN s.sub_state = '3' THEN 'UPGRADE'
		WHEN s.sub_state = '4' THEN 'DOWNGRADE'
		WHEN s.sub_state = '5' THEN 'EXTENDED'
		WHEN s.sub_state = '6' THEN 'TRANSFERRED'
		WHEN s.sub_state = '9' THEN 'BLOCKED'	
		WHEN s.sub_state = '10' THEN 'CHANGED'	
		ELSE 'UNKNOWN'
	END) AS OldProductSubState,
	pg2.name AS NewProductGroup,
	pr2.name AS NewProductName,
	(CASE 
		WHEN s2.state = '2' THEN 'ACTIVE'
		WHEN s2.state = '3' THEN 'ENDED'
		WHEN s2.state = '4' THEN 'FROZEN'
		WHEN s2.state = '8' THEN 'CREATED'
		ELSE 'UNKNOWN'
	END) AS NewProductState,
	(CASE 
		WHEN s2.sub_state = '1' THEN 'NONE'
		WHEN s2.sub_state = '3' THEN 'UPGRADE'
		WHEN s2.sub_state = '4' THEN 'DOWNGRADE'
		WHEN s2.sub_state = '5' THEN 'EXTENDED'
		WHEN s2.sub_state = '6' THEN 'TRANSFERRED'
		WHEN s2.sub_state = '9' THEN 'BLOCKED'	
		WHEN s2.sub_state = '10' THEN 'CHANGED'	
		ELSE 'UNKNOWN'
	END) AS NewProductSubState
FROM
	SUBSCRIPTIONS s
JOIN
	PERSONS p
ON
	s.owner_center = p.center
AND
	s.owner_id = p.id
JOIN
	PRODUCTS pr
ON
	pr.center = s.subscriptiontype_center
AND
	pr.id = s.subscriptiontype_id
JOIN
	PRODUCT_GROUP pg
ON
	pr.primary_product_group_id = pg.id
JOIN
	SUBSCRIPTIONS s2
ON
	s.changed_to_center = s2.center
AND
	s.changed_to_id = s2.id
JOIN
	PRODUCTS pr2
ON
	pr2.center = s2.subscriptiontype_center
AND
	pr2.id = s2.subscriptiontype_id
JOIN
	PRODUCT_GROUP pg2
ON
	pr2.primary_product_group_id = pg2.id
WHERE
	s.sub_state IN ('3', '4','10')