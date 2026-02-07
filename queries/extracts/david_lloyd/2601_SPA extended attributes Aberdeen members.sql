-- This is the version from 2026-02-05
--  
SELECT
pea.name,
pea.txtvalue,
p.external_id
FROM
person_ext_attrs pea
JOIN
persons p
ON
p.center = pea.personcenter
AND p.id = pea.personid
WHERE
p.center = 69
AND pea.name IN (
'HOMESPA',
'AWAYSPA')