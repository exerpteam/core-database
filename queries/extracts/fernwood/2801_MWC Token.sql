-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        p.center||'p'||p.id as "Person ID"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,pea.txtvalue AS "MWC Token"
FROM persons p
LEFT JOIN person_ext_attrs pea
        ON p.center = pea.personcenter
        AND p.id = pea.personid
        AND pea.name = '_eClub_WellnessCloudUserPermanentToken'
WHERE 
        p.center||'p'||p.id in (:PersonID) 