-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        p.center ||'p'||p.id AS "Exerp Person id"
        ,pea.txtvalue
FROM persons p
JOIN person_ext_attrs pea ON pea.personcenter = p.center AND pea.personid = p.id and pea.name = '_eClub_OldSystemPersonId'