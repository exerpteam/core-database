-- The extract is extracted from Exerp on 2026-02-08
-- PT level attriute populated on PT staff accounts on Exerp as part of (SR-262964)
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
	E.Name = 'PTLevel'
AND	
    E.TXTVALUE IS NOT NULL