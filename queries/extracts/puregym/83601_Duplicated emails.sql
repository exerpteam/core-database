SELECT
        pea.txtvalue AS email,
        count(*) AS total,
        string_agg(p.center || 'p' || p.id || ' (' || (CASE p.status 
                                                WHEN 0 THEN 'L'
                                                WHEN 1 THEN 'A' 
                                                WHEN 2 THEN 'I'
                                                WHEN 3 THEN 'TI'
                                                WHEN 6 THEN 'P'
                                                WHEN 9 THEN 'C'
                                                ELSE 'UKN' END) || ')', ';')
FROM puregym.persons p
JOIN puregym.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid
WHERE
        p.status NOT IN (4,5,7,8)
        AND p.sex NOT IN ('C')
        AND pea.name = '_eClub_Email'
        AND pea.txtvalue IS NOT NULL
GROUP BY
        pea.txtvalue
HAVING count(*) > 1