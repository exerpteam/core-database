select distinct
	c.shortname as club_name,
	p.center ||'p'|| p.id as id_socio, 
	p.fullname as full_name,
	prod.name as nome_clipcard,
	--STRING_AGG(DISTINCT pgAll.NAME, ' ; ') AS All_Prod_Groups,
	--STRING_AGG(DISTINCT CAST(pgAll.id AS VARCHAR), ' ; ') AS All_Prod_Groups,
	TO_TIMESTAMP(cl.valid_from / 1000) as data_vendita_clipcard,
	TO_TIMESTAMP(cl.valid_until / 1000) as data_scadenza_clipcard,
	cl.clips_left as clips_left,
	case 
		cl.finished 
			WHEN 'FALSE' THEN 'Active'
			WHEN 'TRUE' THEN 'Used'
			END as status,
	prod.price as prezzo_listino,
	invl.total_amount as clipcard_sales_price,
	inv.employee_center || 'emp' || inv.employee_id as employee_id,
    invl.CENTER || 'inv' || invl.ID as invoice_line
	from 
		clipcards cl 
	join 
		products prod 
		on cl.id = prod.id
	JOIN 
		PERSONS p 
		ON p.CENTER = cl.OWNER_CENTER 
		AND p.ID = cl.OWNER_ID
	join 
		centers c
		on c.id = cl.center 
		and c.country = 'IT'
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
     	INVOICE_LINES_MT invl
 		ON invl.CENTER = cl.INVOICELINE_CENTER
    	AND invl.ID = cl.INVOICELINE_ID
    	AND invl.SUBID = cl.INVOICELINE_SUBID
	JOIN invoices inv
		on inv.center = invl.CENTER
		AND inv.ID = invl.ID
	where 
		cl.center in ($$scope$$)
	and 
		prod.blocked = 0
	AND 
		prod.PTYPE = 4
	and 
		TO_TIMESTAMP(cl.valid_from / 1000) >= ($$data_vendita_clipcard_da$$)
	and 
		TO_TIMESTAMP(cl.valid_from / 1000) <= ($$data_vendita_clipcard_fino_a$$)
	and 
		pgAll.id in ('53401')