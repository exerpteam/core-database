SELECT DISTINCT
    p.center ||'p'|| p.id                 AS person,
    je.creatorcenter||'emp'||je.creatorid AS employee
FROM
    persons p
JOIN
    person_ext_attrs pea
ON
    p.center= pea.personcenter
AND p.id=pea.personid
JOIN
    journalentries je
ON
    p.id=je.person_id
AND p.center=je.person_center
AND je.name='Person created'
WHERE
    p.national_id IS NULL
AND je.creation_time > :time
AND NOT EXISTS
    (
        SELECT
            *
        FROM
            person_ext_attrs pea2
        WHERE
            p.center= pea2.personcenter
        AND p.id=pea2.personid
        AND pea2.name= '_eClub_PassportNumber')
        AND je.creatorcenter = 100 AND je.creatorid = 1203