-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT *
FROM
	Products P
INNER JOIN
	Centers C ON C.ID = P.Center
WHERE 
	P.show_on_web = 1
AND
	P.PType = 4

 