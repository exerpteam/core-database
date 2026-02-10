-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT  
        p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,p.center||'p'||p.id AS "Person ID" 
        ,p.external_id AS "External ID"
        ,pea.txtvalue AS PersonId                                             
FROM    
        persons p 
JOIN 
        person_ext_attrs pea 
        ON p.center = pea.personcenter 
        AND p.id = pea.personid 
        AND pea.name = '_eClub_OldSystemPersonId'                                               
WHERE 
        pea.txtvalue in (:personID)


