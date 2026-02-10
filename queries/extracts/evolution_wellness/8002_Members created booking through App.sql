-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
        pcl.person_center||'p'||pcl.person_id AS PersonID
        ,c.name
FROM        
        evolutionwellness.persons p
JOIN
        evolutionwellness.person_change_logs pcl
        ON pcl.person_center = p.center
        AND pcl.person_id = p.id 
JOIN
        evolutionwellness.centers c
        ON c.id = p.center          
WHERE
        p.center IN (:Scope)
        AND 
        pcl.employee_center ||'emp'||pcl.employee_id = '999emp603'
    