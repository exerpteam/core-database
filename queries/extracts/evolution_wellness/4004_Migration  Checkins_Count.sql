-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        pea.txtvalue AS PersonId,
        COUNT(*) AS total_checkins
FROM evolutionwellness.persons p
JOIN evolutionwellness.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
JOIN evolutionwellness.checkins ch ON p.center = ch.person_center AND p.id = ch.person_id
WHERE
        p.center IN (:Scope)
        AND p.sex NOT IN ('C')
        AND ch.identity_method IS NULL
		AND pea.txtvalue IS NOT NULL
GROUP BY
        pea.txtvalue