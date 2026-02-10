-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.lastname,
p.firstname,
p.center||'p'||p.id as personid,
    pea.txtvalue AS email

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

where pea.txtvalue in ('msabala@chelseapiers.com','bscarmazzo@chelseapiers.com')