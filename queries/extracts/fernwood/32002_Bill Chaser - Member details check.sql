-- The extract is extracted from Exerp on 2026-02-08
--  
select 
        p.center ||'p'|| p.id AS "Person ID"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,p.zipcode AS "Post Code"
        ,p.city AS "City"

FROM cashcollectioncases cc

LEFT join persons p 
        ON p.center = cc.personcenter 
        AND p.id = cc.personid
        
WHERE cc.currentstep = 2
AND p.zipcode is null
AND p.city is null 