SELECT c.id AS "clubID",
	c.name AS "clubName",
	p.center || 'p' || p.id AS "personKey",
	pea.txtvalue AS "Comment"
FROM centers c
JOIN person_ext_attrs pea ON pea.personcenter = c.id
JOIN persons p ON pea.personcenter = p.center
	AND pea.personid = p.id
WHERE pea.name = '_eClub_Comment'
	AND pea.txtvalue IS NOT NULL
--AND p.status IN (1) --1 active
ORDER BY c.id