SELECT
    p.PERSONTYPE,
    
        CASE
            WHEN SUBSTR(pea.TXTVALUE,0,3) != '+44'
            THEN 1
            ELSE 0
        END AS "International Number Count"
FROM
    persons p
JOIN
    person_ext_attrs pea
ON
 pea.name = '_eClub_PhoneHome'
AND pea.PERSONCENTER = p.center
AND pea.PERSONID = p.id
WHERE
    pea.TXTVALUE IS NOT NULL
    and p.center = 100
/*GROUP BY
    p.PERSONTYPE*/