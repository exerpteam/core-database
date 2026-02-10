-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
	 prod.NAME AS product_name, 
     r.ROLENAME as Required_Role,
     prod.center                                                                                        
 FROM
	PRODUCTS prod
JOIN ROLES r ON r.ID = prod.REQUIREDROLE
WHERE prod.center IN (24)
         AND prod.PTYPE IN ($$pType$$)








