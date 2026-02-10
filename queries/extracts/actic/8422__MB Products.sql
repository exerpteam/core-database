-- The extract is extracted from Exerp on 2026-02-08
-- In work extract. Can be removed
/**
* Creator: Martin Blomgren.
* Purpose: lists products in a given scope.
* Seems to be an in-work extract
*
*/
SELECT
	prod.CENTER,
	cen.SHORTNAME CLUB,
	prod.ID,
	prod.GLOBALID,
	prod.id,
	prod.NAME,
	prod.COMENT,
	prod.PRICE,
	prod.NEEDS_PRIVILEGE	SHOW_IN_SALE,
	prod.BLOCKED,
	prod.PRIMARY_PRODUCT_GROUP_ID,
	prod.PRODUCT_ACCOUNT_CONFIG_ID,
	prod.REQUIREDROLE,
	prod.ptype,
	prod.SHOW_ON_WEB


FROM
	products prod
JOIN centers cen
ON
    cen.ID = prod.CENTER
WHERE
prod.center IN (:Scope)
--AND prod.ptype = 10
