-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-3050
WITH
          params AS
          (
              SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'),'YYYY-MM-DD'), c.id) AS FromDate,
                  c.id AS CENTER_ID,
                 datetolongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') + interval '1 day','YYYY-MM-DD'), c.id) AS ToDate
              FROM
                  centers c
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
        ,CASE
                WHEN s.center IS NOT NULL THEN pro.name
                WHEN cc.center IS NOT NULL THEN procc.name
                WHEN sao.id IS NOT NULL THEN mpr.cached_productname
        ELSE 'Gym Access'
        END AS "Privilege used"
        ,acg.name AS "Activity Group"
FROM    
        participations part
JOIN    
        persons p 
        ON p.center = part.participant_center
        AND p.id = part.participant_id
JOIN    
        bookings b
        ON b.center = part.booking_center
        AND b.id = part.booking_id
JOIN    
        params 
        ON params.CENTER_ID = part.booking_center
JOIN 
        activity ac
        ON b.activity = ac.id  
JOIN 
        activity_group acg
        ON acg.id = ac.activity_group_id  
LEFT JOIN
        person_ext_attrs covid
        ON covid.personcenter = p.center
        AND covid.personid = p.id
        AND covid.name = 'covidpassport'     
LEFT JOIN 
        privilege_usages pu
        ON pu.target_service = 'Participation'
        AND pu.target_center = part.center
        AND pu.target_id = part.id   
LEFT JOIN
        subscriptions s
        ON s.owner_center = pu.person_center
        AND s.owner_id = pu.person_id
        AND s.center = pu.source_center
        AND s.id = pu.source_id
LEFT JOIN 
        products pro
        ON pro.center = s.subscriptiontype_center
        AND pro.id = s.subscriptiontype_id        
LEFT JOIN
        clipcards cc
        ON cc.owner_center = pu.person_center
        AND cc.owner_id = pu.person_id
        AND cc.center = pu.source_center
        AND cc.id = pu.source_id
	AND cc.subid = pu.source_subid   
LEFT JOIN 
        products procc
        ON procc.center = cc.center
        AND procc.id = cc.id
LEFT JOIN 
        subscription_addon sao
        ON sao.id = pu.source_id
        AND pu.source_center IS NULL
        AND pu.target_service = 'Participation'
LEFT JOIN 
        masterproductregister mpr
        ON mpr.id = sao.addon_product_id                                   
WHERE 
        p.center in (:scope)
        AND  
        b.starttime BETWEEN params.FromDate AND params.ToDate
        AND 
        ac.activity_group_id in ('6','5','4','8')
        AND 
        (covid.txtvalue = 'false'
        OR
        covid.txtvalue IS NULL)