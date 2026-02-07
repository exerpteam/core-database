SELECT
        p.external_id,
        pea.txtvalue AS agilea_id
FROM puregym_switzerland.persons p
JOIN puregym_switzerland.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_OldSystemPersonId'
