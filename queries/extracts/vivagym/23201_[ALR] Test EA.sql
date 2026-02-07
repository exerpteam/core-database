SELECT c.id AS "clubID",
	c.name AS "clubName",
	p.center || 'p' || p.id AS "personKey",
    p.external_id AS "external_id",
	pea.txtvalue AS "value EA",
    p.fullname AS "Full Name"
FROM centers c
JOIN person_ext_attrs pea ON pea.personcenter = c.id
JOIN persons p ON pea.personcenter = p.center
	AND pea.personid = p.id
WHERE pea.name = 'AdminActionBAF1225'
	AND pea.txtvalue = 'true'