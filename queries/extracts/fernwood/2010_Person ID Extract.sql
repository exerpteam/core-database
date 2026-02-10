-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        p.center ||'p'||p.id AS "Exerp Person ID"
        ,p.fullname AS "Full Name"
        ,pea.txtvalue AS "Legacy Person id"
		,p.external_id AS "External ID"
FROM persons p 
JOIN person_ext_attrs  pea
        ON p.center = pea.personcenter
        AND p.id = pea.personid
        AND pea.name = '_eClub_OldSystemPersonId'
WHERE 
	p.center in (:Scope)


