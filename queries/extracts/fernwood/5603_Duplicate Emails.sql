-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.center ||'p'|| p.id AS "Person ID"
        ,p.external_id AS "External ID"
        ,c.shortname AS "Club"
        ,CASE p.status
                WHEN 0 THEN 'Lead'
                WHEN 1 THEN 'Active'
                WHEN 2 THEN 'Inactive'
                WHEN 3 THEN 'Temporary Inactive'
                WHEN 4 THEN 'Transferred'
                WHEN 5 THEN 'Duplicate'
                WHEN 6 THEN 'Prospect'
                WHEN 7 THEN 'Deleted'
                WHEN 8 THEN 'Anonymized'
                WHEN 9 THEN 'Contact'
        END AS "Person Status"
        ,pe.txtvalue
        ,t1.Total                
FROM
        (
        SELECT pea.txtvalue AS Email,count(*)  AS Total
        FROM person_ext_attrs pea
        WHERE 
                pea.NAME = '_eClub_Email'
                AND
                pea.txtvalue is not null
        GROUP BY pea.txtvalue 
        )t1
JOIN
        person_ext_attrs pe
        ON pe.txtvalue = t1.Email
        AND pe.name = '_eClub_Email'
JOIN
        persons p 
        ON p.center = pe.personcenter             
        AND p.id = pe.personid
JOIN 
        centers c 
        ON c.id = p.center        
WHERE
        t1.Total > 1        
               