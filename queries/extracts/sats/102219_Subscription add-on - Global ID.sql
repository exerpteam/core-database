-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
    m.globalid as "Global ID",
    prod.name                                    AS "Product name",
    m.state as "add-on state"
   
 FROM
     masterproductregister m

     
JOIN products prod
 ON
     m.globalid = prod.globalid

 
 WHERE
 prod.center in (:scope)
 and prod.ptype = 13