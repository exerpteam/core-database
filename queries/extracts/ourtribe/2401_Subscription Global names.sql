-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    distinct

    prod.NAME AS "NAME",
	prod.GLOBALID AS "GLOBALNAME"
    
   
FROM 
    PRODUCTS prod 

WHERE

PROD.PTYPE = 10

ORDER BY PROD.NAME
