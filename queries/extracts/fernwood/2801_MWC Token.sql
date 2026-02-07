SELECT 
        p.center||'p'||p.id as "Person ID"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,pea.txtvalue AS "MWC Token"
FROM fernwood.persons p
LEFT JOIN fernwood.person_ext_attrs pea
        ON p.center = pea.personcenter
        AND p.id = pea.personid
        AND pea.name = '_eClub_WellnessCloudUserPermanentToken'
WHERE 
        p.center||'p'||p.id in (:PersonID) 