WITH
        params AS
        (
        SELECT
                /*+ materialize */
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
                centers c
        ),
        comp AS
        (
        SELECT 
                cc.center
                ,cc.id
                ,cc.subid
                ,pro.name
                ,cc.owner_center
                ,cc.owner_id
                ,pgl.product_group_id
        FROM 
                fernwood.clipcards cc
        JOIN 
                fernwood.products pro 
                ON pro.center = cc.center
                AND pro.id = cc.ID 
        JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = pro.center
                AND pgl.product_id = pro.id
                AND pgl.product_group_id in (11801,401)
        )                          
SELECT  
        b.name AS "Class Name"
        ,TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD') AS "Class Date" 
        ,TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI') AS "Class Time"
        ,p.center||'p'||p.id AS "Person ID"
        ,p.fullname AS "Full Name"        
        ,CASE
                WHEN part.user_interface_type = 0 THEN 'OTHER'
                WHEN part.user_interface_type = 1 THEN 'CLIENT'
                WHEN part.user_interface_type = 2 THEN 'WEB'
                WHEN part.user_interface_type = 3 THEN 'KIOSK'
                WHEN part.user_interface_type = 4 THEN 'SCRIPT'
                WHEN part.user_interface_type = 5 THEN 'API'
                WHEN part.user_interface_type = 6 THEN 'MOBILE API'
                ELSE 'UNKNOWN'
        END AS "Booking creation interface"
        ,CASE
                WHEN part.cancelation_interface_type = 0 THEN 'OTHER'
                WHEN part.cancelation_interface_type = 1 THEN 'CLIENT'
                WHEN part.cancelation_interface_type = 2 THEN 'WEB'
                WHEN part.cancelation_interface_type = 3 THEN 'KIOSK'
                WHEN part.cancelation_interface_type = 4 THEN 'SCRIPT'
                WHEN part.cancelation_interface_type = 5 THEN 'API'
                WHEN part.cancelation_interface_type = 6 THEN 'MOBILE API'
                ELSE ''
        END AS "Booking cancellation interface"
        ,part.state AS "Booking Status" 
        ,part.cancelation_reason AS "Cancel Reason"
        ,ps.name AS "Privilege used"     
        ,acg.name AS "Activity Group"
        ,instructor.fullname AS "Instructor"
        ,CASE
                WHEN comp.product_group_id = 401 THEN comp.name 
                ELSE NULL
        END AS "Comp session used"
        ,comp.name AS "Product used"
        ,CASE
                WHEN comp.product_group_id = 401 THEN 'Complimentary Sessions'
                WHEN comp.product_group_id = 11801 THEN 'Intro offers'
                ELSE 'Other'
        END AS "Product Group" 
FROM    
        fernwood.participations part
JOIN    
        fernwood.persons p 
        ON p.center = part.participant_center
        AND p.id = part.participant_id
JOIN    
        fernwood.bookings b
        ON b.center = part.booking_center
        AND b.id = part.booking_id
JOIN    
        params 
        ON params.CENTER_ID = part.booking_center
JOIN 
        fernwood.activity ac
        ON b.activity = ac.id  
JOIN 
        fernwood.activity_group acg
        ON acg.id = ac.activity_group_id               
LEFT JOIN 
        fernwood.privilege_usages pu
        ON pu.target_service = 'Participation'
        AND pu.target_center = part.center
        AND pu.target_id = part.id 
LEFT JOIN 
        fernwood.participations AS pa 
        ON pa.center = pu.target_center
        AND pa.id = pu.target_id
LEFT JOIN 
        fernwood.privilege_grants AS pg 
        ON pu.grant_id = pg.id
LEFT JOIN
        fernwood.privilege_sets ps
        ON ps.id = pg.privilege_set                    
LEFT JOIN
        fernwood.staff_usage su
        ON su.booking_center = b.center
        AND su.booking_id = b.id
        AND su.state = 'ACTIVE'  
LEFT JOIN 
        fernwood.persons instructor
        ON instructor.CENTER = su.person_center
        AND instructor.id = su.person_id  
LEFT JOIN
        comp
        ON comp.owner_center = p.center
        AND comp.owner_id = p.id
        AND comp.center = pu.source_center
        AND comp.id = pu.source_id 
        AND comp.subid = pu.source_subid                                                                     
WHERE 
        p.center in (:Scope)
        AND  
        b.starttime BETWEEN params.FromDate AND params.ToDate
        AND 
        ac.activity_group_id in (:ActivityGroupID)

