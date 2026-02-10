-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	center||'p'||id AS PersonID
	,co_name
	,national_id
	,resident_id
FROM
	persons
WHERE 
	center = 352
	AND
	co_name IS NOT NULL
	AND
	co_name != ''



