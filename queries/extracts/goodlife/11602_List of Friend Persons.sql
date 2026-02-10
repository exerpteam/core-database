-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT p.center || 'p' || p.id AS "PersonID",p.*

FROM Persons p

WHERE p.persontype = 3