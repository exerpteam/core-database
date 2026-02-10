-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
      per.*,
		p.*
FROM
        PERSON_EXT_ATTRS per
JOIN PERSONS p
	ON p.CENTER = per.PERSONCENTER AND p.ID = per.PERSONID
WHERE
        per.name = 'HOTCONTACTSTATUS' AND per.TXTVALUE LIKE 'POTENTIAL' 
        OR per.name = 'HOTCONTACTSTATUS' AND per.TXTVALUE LIKE 'YES'