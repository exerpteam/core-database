WITH active_members AS
        (
        SELECT 
                per.center||'p'||per.id as PersonID
                ,per.external_id
                ,s.start_date
                ,p.name
                ,pgl.product_group_id
                ,per.center       
        FROM
                fernwood.subscriptions s
        JOIN
                fernwood.subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
        JOIN
                fernwood.products p
                ON p.center = st.center
                AND p.id = st.id
        JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = p.center  
                AND pgl.product_id = p.id
                AND pgl.product_group_id IN (5601)
        JOIN
                fernwood.persons per
                ON per.center = s.owner_center
                AND per.id = s.owner_id        
        WHERE
                s.state IN (2,4,8)  
                AND
                per.persontype != 2      
        ),
subs AS
        (
        SELECT 
                per.center||'p'||per.id as PersonID
                ,per.external_id
                ,s.start_date
                ,p.name
                ,pgl.product_group_id 
                ,per.center      
        FROM
                fernwood.subscriptions s
        JOIN
                fernwood.subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
        JOIN
                fernwood.products p
                ON p.center = st.center
                AND p.id = st.id
        JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = p.center  
                AND pgl.product_id = p.id
                AND pgl.product_group_id IN (215,3802)
        JOIN
                fernwood.persons per
                ON per.center = s.owner_center
                AND per.id = s.owner_id        
        WHERE
                s.state IN (2,4,8)        
        ),
clipcards AS
        (
        WITH
          params AS
          (
              SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST(current_date AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS CutDate,
                  c.id AS CENTER_ID     
              FROM
                  centers c
          )
        SELECT
                p.center||'p'||p.id as personID
                ,p.external_id
                ,pro.name
                ,p.center
        FROM
                fernwood.clipcards cc
        JOIN
                fernwood.products pro 
                ON pro.center = cc.center
                AND pro.id = cc.ID
        JOIN 
                fernwood.persons p
                ON cc.owner_center = p.center 
                AND cc.owner_id = p.id  
        JOIN
                params
                ON params.center_id = cc.center                   
        WHERE
                cc.cancelled IS FALSE
                AND 
                cc.valid_until > params.cutDate
                AND 
                pro.name = 'FIIT30 - 10 Sessions'
        )       
SELECT
        t.*
        ,((t.Count_Clipcard_members + t.Count_Subscription_members) * 100) / t.Count_Active_members ||'%' AS coverage
FROM
        (
        SELECT
                c.name AS CenterName
                ,c.id AS ClubID
                ,CASE
                        WHEN am.active_members IS NOT NULL THEN am.active_members
                        ELSE 1 
                END AS Count_Active_members
                ,CASE
                        WHEN sub.sub IS NOT NULL THEN sub.sub
                        ELSE 0 
                END AS Count_Subscription_members
                ,CASE
                        WHEN cc.cc IS NOT NULL THEN cc.cc
                        ELSE 0 
                END AS Count_Clipcard_members
        FROM
                centers c
        LEFT JOIN
                (SELECT
                        count(*) as active_members
                        ,center
                FROM
                        active_members 
                GROUP BY center   
                )am ON am.center = c.id
        LEFT JOIN
                (SELECT
                        count(*) AS sub
                        ,center
                FROM
                        subs 
                GROUP BY center   
                )sub ON sub.center = c.id 
        LEFT JOIN
                (SELECT
                        count(*) AS cc
                        ,center
                FROM
                        clipcards 
                GROUP BY center   
                )cc ON cc.center = c.id 
        WHERE
                c.id IN (:Scope)      
        )t 
                                                                                                                                                 
                    
             
                           