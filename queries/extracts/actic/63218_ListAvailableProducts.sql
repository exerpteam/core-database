
/**
* Creator: Martin Blomgren.
* Purpose: lists products in a given scope.
* Seems to be an in-work extract
*
*/
SELECT
	prod.GLOBALID,
	prod.NAME
	
FROM
	products prod
JOIN centers cen
ON
    cen.ID = prod.CENTER
WHERE
cen.COUNTRY IN ('SE','NO')
AND prod.ptype = 10
GROUP BY 
	prod.GLOBALID,
	prod.NAME
