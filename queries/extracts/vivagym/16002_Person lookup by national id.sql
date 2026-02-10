-- The extract is extracted from Exerp on 2026-02-08
--  
select external_id from (
SELECT
    p.external_id, p.last_modified
FROM 
        persons p   

WHERE 
    p.national_id IN (:nationalId)
    
UNION

SELECT
    p.external_id, p.last_modified
FROM 
        persons p   

WHERE 
    p.national_id IN (SELECT 
                          CASE 
                              WHEN LENGTH(:nationalId) > 1 
                              THEN SUBSTRING(:nationalId FROM 1 FOR LENGTH(:nationalId) - 1) || '-' || SUBSTRING(:nationalId FROM LENGTH(:nationalId))
                              ELSE :nationalId
                          END
                      FROM (VALUES (1)) AS dummy)
                      
UNION

SELECT
    p.external_id, p.last_modified
FROM 
        persons p   

WHERE
    p.national_id IN (SELECT 
                          CASE 
                              WHEN LENGTH(:nationalId) > 1 
                              THEN SUBSTRING(:nationalId FROM 1 FOR 1) || '-' || SUBSTRING(:nationalId FROM 2 FOR LENGTH(:nationalId) - 2) || '-' || SUBSTRING(:nationalId FROM LENGTH(:nationalId))
                              ELSE :nationalId
                          END
                      FROM (VALUES (1)) AS dummy)
                      
) t1
 order by last_modified desc
                
LIMIT 1