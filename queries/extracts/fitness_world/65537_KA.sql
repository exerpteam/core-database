-- The extract is extracted from Exerp on 2026-02-08
--  
		select DISTINCT
		prod.NAME,
		prod.GLOBALID,
		ppgl.PRODUCT_GROUP_ID
		from 
		PRODUCT_AND_PRODUCT_GROUP_LINK ppgl
		JOIN PRODUCTS prod
		ON prod.CENTER = ppgl.PRODUCT_CENTER
		AND prod.ID = ppgl.PRODUCT_ID
		AND prod.PTYPE in (10, 5)