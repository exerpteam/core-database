-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT p.center||'p'||p.id AS "Member ID", p.external_id, p.center, p.id, p.firstname, p.lastname, p.country, TO_CHAR(longtodate(p.LAST_MODIFIED), 'dd-MM-yyyy HH24:MI') AS "Sidst opdateret" FROM PERSONS P
WHERE p.center in (:Center) 
--P.country = 'SE'