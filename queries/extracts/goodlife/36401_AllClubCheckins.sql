-- The extract is extracted from Exerp on 2026-02-08
--  
WITH RECURSIVE province (center,area) AS (

    -- All center area links in system scope
    
    SELECT
    
    c.id AS center
    ,ac.area AS area

    FROM
    
    centers c
    
    JOIN area_centers ac
    ON c.id = ac.center
       
    UNION
    
    SELECT
    
    p.center
    ,a.parent AS area
    
    FROM
    
    province p
    
    JOIN areas a
    ON p.area = a.id
    AND a.root_area = 1
    

), property_name AS (

    SELECT TEXT 'PersonInvoiceCollectionMinimumAmount' AS name
    
), areas_in_areas AS (

    -- City - Province Links
    
    SELECT
    
    a.id AS city
    ,a2.id AS province
    
    FROM
    
    areas a
    
    JOIN areas a2
    ON a.parent = a2.id
    AND a.root_area = 1
    AND a2.root_area = 1
    AND a2.parent = 2


), centers_list AS (
    
    -- List of all centers and the applicable configuration
   
    SELECT
    
    *
    
    FROM
    
    (
    
    SELECT
    
    a.id AS province_id
    ,a.name AS province
    ,a2.id AS city_id
    ,a2.name AS city
    ,c.id AS center_id
    ,c.name AS Center
    ,CASE
        WHEN center_config.txtvalue IS NOT NULL
        THEN center_config.txtvalue
        WHEN city_config.txtvalue IS NOT NULL
        THEN city_config.txtvalue
        WHEN province_config.txtvalue IS NOT NULL
        THEN province_config.txtvalue
        WHEN canada_config.txtvalue IS NOT NULL
        THEN canada_config.txtvalue
        WHEN system_config.txtvalue IS NOT NULL
        THEN system_config.txtvalue
        ELSE '0' -- Default Value - not stored in database (?), so hard code
    END AS txtvalue
    
    FROM
    
    centers c
    
    JOIN province cities
    ON c.id = cities.center
    
    JOIN areas a2
    ON a2.id = cities.area
    AND (
        a2.parent BETWEEN 3 AND 11 
        OR a2.id = 220 -- Quebec
    )
    
    JOIN province prov
    ON prov.center = c.id
    
    JOIN areas a
    ON prov.area = a.id
    AND (a.id BETWEEN 3 AND 11
    OR a.id = 220)

    LEFT JOIN  systemproperties center_config
    ON c.id = center_config.scope_id
    AND center_config.scope_type = 'C'
    AND center_config.globalid = (SELECT name FROM property_name)

    LEFT JOIN  systemproperties city_config
    ON a2.id = city_config.scope_id
    AND city_config.scope_type = 'A'
    AND city_config.globalid = (SELECT name FROM property_name)
    
    LEFT JOIN  systemproperties province_config
    ON a.id = province_config.scope_id
    AND province_config.scope_type = 'A'
    AND province_config.globalid = (SELECT name FROM property_name)
    
    LEFT JOIN (
    
        SELECT
        
        c_can.id
        ,sp.txtvalue
        
        FROM
        
        centers c_can

        CROSS JOIN 
            
        systemproperties sp

        WHERE
         
        sp.scope_type = 'A'
        AND sp.globalid = (SELECT name FROM property_name)
        AND sp.scope_id = 2    
        
    ) canada_config
    ON canada_config.id = c.id
    
    LEFT JOIN (
    
        SELECT
        
        c_sys.id
        ,sp.txtvalue
        
        FROM
        
        centers c_sys

        CROSS JOIN 
            
        systemproperties sp

        WHERE
         
        sp.scope_type = 'T'
        AND sp.globalid = (SELECT name FROM property_name)
        AND sp.scope_id = 1    
        
    ) system_config
    ON system_config.id = c.id
    ) a

    WHERE
    
    txtvalue != '0'
    
), temp_list AS (

    SELECT DISTINCT

    
    s.center||'ss'||s.id AS subscription_id
    ,prod.name
    ,s.center AS subscription_center_id
    ,c.name AS subscription_center_name
    ,bi_decode_field('SUBSCRIPTIONS', 'STATE', s.state) AS subscription_state
    ,p.center||'p'||p.id AS person_id
    ,p.center AS person_center
    ,c2.name person_center_name
    

    ,p.center
    ,p.id


    FROM

    subscriptions s

    JOIN persons p
    ON p.center = s.owner_center
    AND p.id = s.owner_id
    AND s.state IN (2,4,8)
    -- Subscription will not be frozen
    AND s.center NOT IN 
    (SELECT center_id FROM centers_list)
    -- (5,11,29,30,32,47,50,55,108,58,60,62,79,223,80,81,84,104,105,106,109,110,112,241,149,151,154,155,177,164,180,169,173,175,181,183,184,185,186,189,212,202,233,234,235,246,247,255,261,262,264,268,270,266,273,276,294,347,299,336,339,340,341,288,315,317,131,296,297,38,138,182,187)
    -- Person will not be billed
    AND p.center IN (SELECT center_id FROM centers_list)
    -- (5,11,29,30,32,47,50,55,108,58,60,62,79,223,80,81,84,104,105,106,109,110,112,241,149,151,154,155,177,164,180,169,173,175,181,183,184,185,186,189,212,202,233,234,235,246,247,255,261,262,264,268,270,266,273,276,294,347,299,336,339,340,341,288,315,317,131,296,297,38,138,182,187)
    
    JOIN subscriptiontypes st
    ON st.center = s.subscriptiontype_center 
    AND st.id = s.subscriptiontype_id
    AND st.st_type IN (1,2)

    
    JOIN products prod
    ON prod.center = s.subscriptiontype_center 
    AND prod.id = s.subscriptiontype_id

    JOIN centers c
    ON c.id = s.center

    JOIN centers c2
    ON c2.id = p.center
    
    
), params AS (
  
  SELECT
  
    datetolongTZ(TO_CHAR(DATE('2020-06-15'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) AS cutDateFrom,
    c.id AS centerid

  FROM

    goodlife.centers c

  WHERE

    c.time_zone IS NOT NULL

), checkin_data AS (

    SELECT
    
    p.center
    ,p.id
    ,c.checkin_center
    ,CAST(COUNT(*) AS INTEGER) AS total_checkins
    
    FROM

    temp_list p
    
    JOIN checkins c
    ON c.person_center = p.center
    AND c.person_id = p.id

    JOIN params par
    ON c.checkin_center = par.centerid
    AND c.checkin_time > par.cutDateFrom

   GROUP BY 

    p.center
    ,p.id
    ,c.checkin_center

)

SELECT

p.person_id
,p.subscription_id
,p.name AS product
,p.subscription_center_id
,p.subscription_center_name
,p.subscription_state
,p.person_center
,p.person_center_name
,c.checkin_center
,CASE
    WHEN c.checkin_center IN (SELECT center_id FROM centers_list)
    THEN TEXT 'Closed'
    WHEN c.checkin_center IS NULL
    THEN TEXT 'N/A'
    ELSE TEXT 'Open'
END AS Open_Closed
,ce.name AS checkin_center
,c.total_checkins

FROM

temp_list p

LEFT JOIN checkin_data c
ON p.center = c.center
AND p.id = c.id

LEFT JOIN centers ce
ON ce.id = c.checkin_center

ORDER BY p.person_id