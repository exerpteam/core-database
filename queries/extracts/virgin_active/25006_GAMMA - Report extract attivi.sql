-- The extract is extracted from Exerp on 2026-02-08
--  
select sc.*, ex.SERVICE FROM EXCHANGED_FILE_SC sc
INNER JOIN
EXCHANGED_FILE ex

ON sc.ID = ex.ID
 WHERE 
sc.SCOPE_ID IN(24,100) AND sc.STATUS = 'ACTIVE'