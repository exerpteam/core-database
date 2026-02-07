SELECT 
	CONCAT(CONCAT(cast(pE.CENTER as char(3)),'p'), cast(pe.ID as varchar(8))) as personId 
FROM
	PERSONS pE
INNER JOIN
	SUBSCRIPTIONS S ON pe.ID = s.OWNER_ID AND pe.CENTER = s.OWNER_CENTER
INNER JOIN
	SUBSCRIPTIONTYPES st ON st.ID = s.SUBSCRIPTIONTYPE_ID AND st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
INNER JOIN 
	PRODUCTS p ON p.ID =st.ID AND p.CENTER = st.CENTER
INNER JOIN 
	CENTERS c ON c.ID  = P.CENTER 
LEFT OUTER JOIN 
	SUBSCRIPTION_ADDON sa ON sa.SUBSCRIPTION_ID = s.ID AND sa.SUBSCRIPTION_CENTER = s.CENTER 

LEFT OUTER JOIN
    MASTERPRODUCTREGISTER mpr ON mpr.ID = sa.ADDON_PRODUCT_ID
LEFT OUTER JOIN 
	PRODUCTS addon ON addon.CENTER = s.CENTER AND addon.GLOBALID = mpr.GLOBALID AND addon.NAME LIKE 'Roaming%Collection%'

WHERE
	c.COUNTRY = 'IT' 

AND 
(
	(
		--c.ID IN (209, 224, 225, 222)
		c.ID NOT IN (223)
		AND
		(
			(  -- OPEN 12 NON DIAZ
				(
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 138.99 
						AND 
						p.NAME NOT LIKE '%Cash%'
					)
					OR
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 1667.88 
						AND 
						p.NAME LIKE '%Cash%'
					)
				)
				AND
				(
					p.NAME LIKE 'Open 12 %' 
				)
			)
			OR 
			( -- OPEN 3 NON DIAZ
				(
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 159.99 
						AND 
						p.NAME NOT LIKE '%Cash%'
					)
					OR
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 479.97
						AND 
						p.NAME LIKE '%Cash%'
					)
				)
				AND
				(
					p.NAME LIKE 'Open 3 %' 
				)
			)
			OR 
			( -- OPEN 24 NON DIAZ
				(
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 129.99 
						AND 
						p.NAME NOT LIKE '%Cash%'
					)
					OR
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 3119.76
						AND 
						p.NAME LIKE '%Cash%'
					)
				)
				AND
				(
					p.NAME LIKE 'Open 24 %' 
				)
			)
		) 
	)
	OR
	(
		c.ID IN (223)
		AND
		(
			( -- OPEN 12 DIAZ
				(
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 99.99 
						AND 
						p.NAME NOT LIKE '%Cash%'
					)
					or
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 1199.88 
						AND 
						p.NAME  LIKE '%Cash%'
					)
				)
				AND
				(
					p.NAME LIKE 'Open 12 %' 
				) 
			)
			OR 
			( -- OPEN 3 DIAZ
				(
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 119.99 
						AND 
						p.NAME NOT LIKE '%Cash%'
					)
					or
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 359.97  
						AND 
						p.NAME  LIKE '%Cash%'
					)
				)
				AND
				(
					p.NAME LIKE 'Open 3 %' 
				) 
			)
			OR 
			( -- OPEN 24 DIAZ
				(
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 92.99 
						AND 
						p.NAME NOT LIKE '%Cash%'
					)
					or
					(
						(s.BINDING_PRICE + NVL(addon.PRICE, 0)) >= 2231.76  
						AND 
						p.NAME  LIKE '%Cash%'
					)
				)
				AND
				(
					p.NAME LIKE 'Open 24 %' 
				) 
			)
		)
	)
)

AND 
	s.STATE IN (2)
ORDER BY 
	p.NAME



