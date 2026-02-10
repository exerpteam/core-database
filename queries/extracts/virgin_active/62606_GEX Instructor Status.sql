-- The extract is extracted from Exerp on 2026-02-08
-- RG - 25.02.22 - created to flag all accounts with the Instructor status extended attribute populdated on
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
AND
	C.ID IN 
	(
	76,
29,
33,
34,
35,
27,
421,
405,
38,
438,
39,
47,
48,
12,
51,
56,
57,
59,
415,
2,
60,
61,
422,
452,
15,
6,
68,
69,
410,
16,
75,
953,
425,
408
)

ORDER BY
	C.Shortname asc