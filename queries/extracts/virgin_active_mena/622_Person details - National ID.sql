-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center||'p'||p.id as PersonID
        ,p.national_id
        ,p.firstname
        ,p.lastname
        ,p.external_id
        ,pea.txtvalue AS PassportID
        ,CASE p.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE
        ,CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS
        ,c.name as Home_Club
FROM 
        persons P
JOIN
        centers c
        ON c.id = p.center
LEFT JOIN
        person_ext_attrs pea 
        ON pea.personcenter = p.center 
        AND pea.personid = p.id
        AND pea.name = '_eClub_PassportNumber'   
WHERE
        p.center IN (:Scope) 
        AND
        p.PERSONTYPE != 2
        AND
        p.STATUS NOT IN (4,7)       
                          