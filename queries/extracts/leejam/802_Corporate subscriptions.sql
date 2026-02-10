-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
   
    prod.GLOBALID "Global Name",
    prod.NAME "Product Name"

  
FROM
    PRODUCTS prod

   
WHERE
 
    
     prod.BLOCKED = 0
AND

prod.PRIMARY_PRODUCT_GROUP_ID in (802,803)