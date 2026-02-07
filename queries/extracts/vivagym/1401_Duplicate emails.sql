

SELECT
        p.external_id,
        p.center || 'p' || p.id,
        CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        peao.txtvalue as email
FROM
        vivagym.persons p
JOIN
        vivagym.person_ext_attrs peao ON p.center = peao.personcenter AND p.id = peao.personid
WHERE
        peao.name = '_eClub_Email'
        AND peao.txtvalue IN 
        (
                SELECT
                        pea.txtvalue
                        --,COUNT(*)
                FROM vivagym.persons p
                JOIN vivagym.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid
                WHERE
                        p.status NOT IN (7)
                        AND pea.name = '_eClub_Email'
                        AND pea.txtvalue IS NOT NULL
                GROUP BY
                        pea.txtvalue
                HAVING COUNT(*) > 1
        )
ORDER BY 4,3