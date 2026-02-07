select distinct
	p.center ||'p'|| p.id as person_id, 
	c.shortname as club,
	p.fullname as full_name,
	prod2.name AS subscription_name,
	s.CENTER || 'ss' || s.ID AS subscription_id,
	sp.PRICE AS subscription_price,
	TO_TIMESTAMP(cl.valid_from / 1000) as data_validita_clipcard,
	TO_TIMESTAMP(cl.valid_until / 1000) as data_scadenza_clipcard,
	prod.name as nome_clipcard,
	cl.clips_initial as clips_vendute,
	cl.clips_left as clips_left,
	cl.cancelled
	FROM
		clipcards cl 
	join 
		products prod 
		on cl.id = prod.id
		and prod.blocked = 0
		and prod.PTYPE = 4
	JOIN
		PRODUCT_GROUP pg
		ON pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
	LEFT JOIN
		PRODUCT_AND_PRODUCT_GROUP_LINK pgLink
		ON pgLink.PRODUCT_CENTER = prod.CENTER
		AND pgLink.PRODUCT_ID = prod.ID
	LEFT JOIN
		PRODUCT_GROUP pgAll
		ON pgAll.ID = pgLink.PRODUCT_GROUP_ID
	JOIN 
		PERSONS p 
		ON p.CENTER = cl.OWNER_CENTER 
		AND p.ID = cl.OWNER_ID
	join 
		centers c
		on c.id = p.center 
		and c.country = 'IT'
	left JOIN SUBSCRIPTIONS S
	    ON s.OWNER_CENTER = p.CENTER
    	AND s.OWNER_ID = p.ID 
		and s.state in (2,4,8)
	LEFT JOIN PRODUCTS prod2
 	 	ON prod2.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     	AND prod2.ID = s.SUBSCRIPTIONTYPE_ID
		and prod2.blocked = 0
		and prod2.PTYPE = 10
	LEFT JOIN SUBSCRIPTION_PRICE sp
	 	ON sp.SUBSCRIPTION_CENTER = s.CENTER
     	AND sp.SUBSCRIPTION_ID = s.ID
     	AND sp.FROM_DATE <= CURRENT_TIMESTAMP
    	 AND (
        	 sp.TO_DATE IS NULL
         	OR sp.TO_DATE > CURRENT_TIMESTAMP)
    	 AND sp.APPLIED = 1
    	 --AND sp.CANCELLED = 0 
	where 
		p.center in ($$scope$$)
	and 
		TO_TIMESTAMP(cl.valid_from / 1000) >= ($$data_validita_clipcard_da$$)
	and 
		TO_TIMESTAMP(cl.valid_from / 1000) <= ($$data_validita_clipcard_fino_a$$)
	and pgAll.id in ('54004')
	