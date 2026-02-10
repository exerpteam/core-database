-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	C.Shortname as Club,
	E.PERSONCENTER || 'p' || E.PERSONID as member_id,
	--E.Name as Attribute,
	E.TXTVALUE as Value
	
FROM 
	PERSON_EXT_ATTRS E
JOIN
	Centers C
	ON C.ID = E.PERSONCENTER
WHERE 
	E.Name = 'InstructorStatus'
AND	
    E.TXTVALUE IS NOT NULL

ORDER BY
	C.Shortname asc