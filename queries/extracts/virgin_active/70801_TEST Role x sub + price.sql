-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.id "center_ID",
	p.CENTER || 'prod' || p.ID "product_id",
    p.NAME "subscription_name",
    r.ROLENAME "required_role",
    p.PRICE "price_club"
FROM
    PRODUCTS p
INNER JOIN 
	subscriptions s
on
	s.id = p.id
LEFT JOIN
    ROLES r
ON
    r.ID = p.REQUIREDROLE
JOIN
    CENTERS c
ON
    c.id = p.CENTER
WHERE 
	p.ptype = '10'
and s.state in ('ACTIVE')
and c.id
IN
	($$scope$$)
