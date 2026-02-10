-- The extract is extracted from Exerp on 2026-02-08
-- Returns available clipcards by PersonID
SELECT 
	c.center as ClipcardCenter,
	p.center || 'p' || p.id AS PersonID,
	p.fullname,
	c.center || 'cc' || c.id || 'cc' || c.subid AS ClipcardID,
	pp.name AS ClipcardName,
	pg.name AS ProductGroup,
	longtodatec(c.valid_from,c.center) AS ValidfromDate,
	c.clips_initial,
	c.clips_left,
	ep.fullname AS AssignedStaff,
	c.cc_comment

FROM persons p

JOIN clipcards c
ON
	c.owner_center = p.center
AND
	c.owner_id = p.id
AND
	c.clips_left > 0
AND 
	c.cancelled = 'f'
AND 
	c.blocked = 'f'

LEFT JOIN persons ep
ON
	ep.center = c.assigned_staff_center
AND
	ep.id = assigned_staff_id

JOIN products pp
ON 
	pp.center = c.center
AND
	pp.id = c.id

JOIN product_group pg
ON
	pg.id = pp.primary_product_group_id
--AND
--	pp.primary_product_group_id = '220'
WHERE
	p.center || 'p' || p.id IN ($$PersonID$$)