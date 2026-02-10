-- The extract is extracted from Exerp on 2026-02-08
-- Created by: Sandra Gupta  Created on: 10.22.24  Created for: GoXPro Integration POC
WITH
        area AS
        (
        SELECT
                ac.center      AS center_id,
                root_area.name AS tree_name
        FROM
                AREA_CENTERS ac
        JOIN
                AREAS a
                ON a.id = ac.AREA
        JOIN
                AREAS root_area
                ON root_area.ID=a.ROOT_AREA
        JOIN
                AREAS root_area_t
                ON root_area_t.ID=root_area.ROOT_AREA    
        JOIN
                centers c
                ON c.id = ac.center
        WHERE
                root_area_t.root_area = 1   
        )
SELECT DISTINCT
        t.activity_id
        ,t.name
        ,t.activity_type
        ,t.valid_from
        ,t.valid_to
FROM
        (
        SELECT DISTINCT
                ac.id AS activity_id
                ,ac.name
                ,CASE ac.ACTIVITY_TYPE 
                        WHEN 1 THEN 'General' 
                        WHEN 2 THEN 'Class' 
                        WHEN 3 THEN 'Resource booking' 
                        WHEN 4 THEN 'Staff booking' 
                        WHEN 5 THEN 'Meeting' 
                        WHEN 6 THEN 'Staff availability' 
                        WHEN 7 THEN 'Resource availability' 
                        WHEN 8 THEN 'ChildCare' 
                        WHEN 9 THEN 'Course program' 
                        WHEN 10 THEN 'Task' 
                        WHEN 11 THEN 'Camp' 
                        WHEN 12 THEN 'Camp elective' 
                        ELSE 'Undefined' 
                END AS activity_type
                ,longtodatec(pc.valid_from,pc.person_center) AS valid_from
                ,longtodatec(pc.valid_to,pc.person_center) AS valid_to
                ,CASE
                        WHEN ps.scope_type = 'A' THEN a.center
                        WHEN ps.scope_type = 'T' THEN area.center_id
                        ELSE ps.scope_id
                END AS scope_center
                ,bp.valid_for
                ,ps.scope_id,ps.scope_type    
                ,p.external_id
        FROM
                privilege_cache pc
        JOIN
                privilege_grants pg
                ON pg.id = pc.grant_id
        JOIN
                privilege_sets ps
                ON ps.id = pg.privilege_set 
        JOIN
                booking_privileges bp
                ON bp.privilege_set = ps.ID      
        JOIN
                participation_configurations pco
                ON bp.group_id = pco.access_group_id
        JOIN
                activity ac
                ON pco.activity_id = ac.id 
                AND pco.access_group_id IS NOT NULL
        JOIN
                persons p
                ON p.center = pc.person_center
                AND p.id = pc.person_id 
        LEFT JOIN
                area_centers a
                ON a.area = ps.scope_id
                AND ps.scope_type = 'A'
        LEFT JOIN
                area 
                ON ps.scope_type = 'T'  
        WHERE 
                ac.state = 'ACTIVE'
                AND
                pc.privilege_type = 'BOOKING' 
				AND ac.activity_type = 4          
        )t
WHERE     
        t.external_id = :external_id