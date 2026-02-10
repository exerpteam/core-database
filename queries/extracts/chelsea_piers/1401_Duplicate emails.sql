-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    
    pea.txtvalue AS email,
STRING_AGG(CAST(p.center||'p'||p.id AS TEXT),',' ) as personid,

count(*)
FROM
    persons p
left JOIN
    chelseapiers.employees e
ON
    p.center = e.personcenter
AND p.id=e.personid
JOIN
    chelseapiers.person_ext_attrs pea
ON
    p.center = pea.personcenter
AND p.id=pea.personid
AND pea.name = '_eClub_Email'
AND pea.txtvalue IS NOT NULL

group by txtvalue
having count(*) > 1