-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	pg.ID,
	pg.NAME AS PRODUCT_GROUP,
	pg.STATE
FROM PRODUCT_GROUP pg
ORDER BY pg.ID