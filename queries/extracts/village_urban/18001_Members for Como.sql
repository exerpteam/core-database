SELECT
    p.external_id AS "MemberID",
	p.firstname AS "Frrst Name",
	p.lastname AS "Last Name",
	pea.txtvalue AS "email"
FROM
    persons p
LEFT JOIN
    person_ext_attrs pea
ON
    pea.personcenter = p.center
AND pea.personid = p.id
AND pea.name = '_eClub_Email'
WHERE
    p.STATUS IN (1,3)
AND p.persontype not in (2,8)
AND pea.txtvalue is NOT NULL
AND p.center IN (:Scope)




