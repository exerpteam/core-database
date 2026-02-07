SELECT 
	prod.center,
	prod.id,
	prod.name,
	prod.ptype,
	prod.show_on_web,
	prod.webname


FROM PRODUCTS prod

WHERE 
	PTYPE = 13
	AND CENTER in ($$Scope$$)


