-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.external_id,
    pea.txtvalue AS old_system_person_id
FROM
    persons p
    JOIN person_ext_attrs pea ON p.center = pea.personcenter
    AND p.id = pea.personid
    AND pea.name = '_eClub_OldSystemPersonId'
WHERE
    p.center in (:scope)