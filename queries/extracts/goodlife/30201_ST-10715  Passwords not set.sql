SELECT
    p.external_id
FROM
    persons p
JOIN
    person_ext_attrs pea
ON
    p.center = pea.personcenter
AND p.id = pea.personid
AND pea.name ='_eClub_Email'
JOIN
    centers c
ON
    p.center = c.id
WHERE
    (
        p.center, p.id) NOT IN
    (
        SELECT
            person_center,
            person_id
        FROM
            journalentries je
        WHERE
            je.creation_time >1569906060000
        AND name = 'Password was updated')
AND p.status =1
AND p.sex !='C'
AND p.center IN ($$scope$$)