-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
   
    prod.GLOBALID "Global Name",
    prod.NAME "Product Name"
  
FROM
    PRODUCTS prod

   
WHERE
 
    prod.PTYPE IN ($$pType$$)
    AND prod.center IN ($$scope$$)
    AND prod.BLOCKED = 0
