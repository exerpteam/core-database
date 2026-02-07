SELECT 
        p.center ||'p'||p.id AS "Exerp Person id"
        ,pea.txtvalue
FROM fernwood.persons p
JOIN fernwood.person_ext_attrs pea ON pea.personcenter = p.center AND pea.personid = p.id and pea.name = '_eClub_OldSystemPersonId'