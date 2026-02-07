SELECT
	cen.EXTERNAL_ID AS Cost,
	prod.center AS CenterId,
	cen.shortname AS CenterName,
--	prod.id AS ProductId,
	DECODE (prod.ptype, 1,'RETAIL', 2,'SERVICE', 4,'CLIPCARD', 5,'JOINING FEE', 8,'GIFTCARD', 10,'SUBSCRIPTION') AS ProductType,
	prod.name,
	prod.price,
	prod.min_price,
	prod.cost_price,
	prod.globalid,
	prod.external_id


FROM
	PRODUCTS prod

/* joining centers table for name and cost center */
JOIN CENTERS cen
ON
	cen.id = prod.center

WHERE
    prod.center in (:ChosenScope)
	AND prod.ptype IN (1, 2, 4)
	AND prod.REQUIREDROLE IS NULL
	AND prod.needs_privilege = 0
	AND prod.BLOCKED = 0
--	AND prod.SHOW_IN_SALE = 1
	
ORDER BY 
	prod.center, 
	prod.ptype,
	prod.name