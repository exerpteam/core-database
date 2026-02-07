SELECT
    COUNT(p.center),
    p.ssn
FROM
    persons p
WHERE
    p.status NOT IN (4,5,7)
    AND p.sex != 'C'
    AND p.ssn IS NOT NULL
    AND p.center IN (9226, 9227, 54, 195)

GROUP BY
    p.ssn
HAVING
    COUNT(p.center) > 1