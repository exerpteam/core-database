WITH 
        Product_priviledge_link AS
        (SELECT 
                id,
                CASE
                        WHEN ID IN (211,15602,16803,15402,16618,17006,16809,16804,16617,25007)  THEN 220
                        WHEN ID IN (220,5203,5403,13409)                                        THEN 223
                        WHEN ID IN (7202,203,12203,12204,19008,23205,45606)                     THEN 215
                        WHEN ID IN (8602,14410,14205,19003,18201)                               THEN 6001
                        WHEN ID IN (206,208,4001,6201,8602)                                     THEN 216
                        WHEN ID IN (204,3801,202,8407,9801,8408,8208)                           THEN 214
                        WHEN ID IN (207,216,18004,9203,9401,9402,14407,16401,15203,16605,20014) THEN 217
                        WHEN ID IN (217)                                                        THEN 221
                        WHEN ID IN (218,19206,219,22802,24805)                                  THEN 218
                        WHEN ID IN (221)                                                        THEN 235
                END AS Product_group
        FROM 
                fernwood.privilege_sets
        WHERE
                id IN (211,15602,16803,15402,16618,17006,16809,16804,16617,25007,220,5203,5403,13409,7202,203,12203,12204,19008,23205,45606,8602,14410,14205,19003,18201,206,208,4001,6201,8602,204,3801,202,8407,9801,8408,8208,207,216,18004,9203,9401,9402,14407,16401,15203,16605,20014,217,218,19206,219,22802,24805,221)        
        )                 
SELECT DISTINCT
        t1."Club Name"
        ,t1."External ID"	
        ,t1.center||'p'||t1.id AS "Person ID"
        ,t1."Member Full Name"
        ,t1."Person Status"
        ,t1."Person Type"
        ,t1."Component"	 
        ,t1."Start Date"
        ,t1."Stop Date"	
        ,t1."Last Visit Date" 
        ,t1."Price"
        --,t1."Type"
FROM
        (
        SELECT
                c.shortname AS "Club Name"
                ,p.external_id AS "External ID"	
                ,p.center 
                ,p.id
                ,p.fullname AS "Member Full Name"
                ,mobile.txtvalue AS "Contact Number"
                ,email.txtvalue AS "Email"
                ,CASE
                        WHEN p.status = 0 THEN 'Lead'
                        WHEN p.status = 1 THEN 'Active'
                        WHEN p.status = 2 THEN 'Inactive'
                        WHEN p.status = 3 THEN 'Temporary Inactive'
                        WHEN p.status = 4 THEN 'Transfered'
                        WHEN p.status = 5 THEN 'Duplicate'
                        WHEN p.status = 6 THEN 'Prospect'
                        WHEN p.status = 7 THEN 'Deleted'
                        WHEN p.status = 8 THEN 'Anonymized'
                        WHEN p.status = 9 THEN 'Contact'
                        ELSE 'Unknown'
                END AS "Person Status"
                ,CASE 
                        WHEN p.persontype = 0 THEN 'PRIVATE' 
                        WHEN p.persontype = 1 THEN 'STUDENT' 
                        WHEN p.persontype = 2 THEN 'STAFF' 
                        WHEN p.persontype = 3 THEN 'FRIEND' 
                        WHEN p.persontype = 4 THEN 'CORPORATE' 
                        WHEN p.persontype = 5 THEN 'ONEMANCORPORATE' 
                        WHEN p.persontype = 6 THEN 'FAMILY' 
                        WHEN p.persontype = 7 THEN 'SENIOR' 
                        WHEN p.persontype = 8 THEN 'GUEST' 
                        WHEN p.persontype = 9 THEN 'CHILD' 
                        WHEN p.persontype = 10 THEN 'EXTERNAL_STAFF' 
                        ELSE 'Undefined' 
                END AS "Person Type"
                ,prod.name AS "Component"	 
                ,s.start_date AS "Start Date"
                ,s.end_date AS "Stop Date"	
                ,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
                ,'Subscription' AS "Type"
                ,pglc.product_group_id AS "Exclude"
                ,prod.globalid AS "GlobalID"
                ,s.subscription_price AS "Price"                            
        FROM
                fernwood.subscriptions s        
        JOIN
                fernwood.subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.ID = s.subscriptiontype_id
                AND st.st_type != 2 
        JOIN
                fernwood.products prod
                ON prod.center = st.center
                AND prod.id = st.id
        JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = prod.center  
                AND pgl.product_id = prod.id
        LEFT JOIN
                fernwood.product_and_product_group_link pglc
                ON pglc.product_center = prod.center
                AND pglc.product_id = prod.id
                AND pglc.product_group_id IN (401,224)  
        JOIN
                fernwood.product_group pg
                ON pg.id = pgl.product_group_id                       
        JOIN
                fernwood.persons p
                ON p.center = s.owner_center
                AND p.id = s.owner_id
                AND p.status NOT IN (2,4,5,7)
        JOIN
                fernwood.centers c
                ON c.id = p.center
        LEFT JOIN
                fernwood.person_ext_attrs mobile
                ON mobile.personcenter = p.center
                AND mobile.personid = p.id
                AND mobile.name = '_eClub_PhoneSMS'
        LEFT JOIN
                fernwood.person_ext_attrs email
                ON email.personcenter = p.center
                AND email.personid = p.id
                AND email.name = '_eClub_Email'
        LEFT JOIN
                (SELECT 
                        max(checkin_time) AS LastVisitDate
                        ,person_center AS PersonCenter
                        ,person_id AS PersonID             
                FROM 
                        fernwood.checkins 
                GROUP BY 
                        person_center
                        ,person_id )la
                ON la.PersonCenter = p.center
                AND la.PersonID = p.id
        JOIN
                fernwood.masterproductregister mpr
                ON mpr.globalid = prod.globalid
                AND mpr.scope_type = 'A'
        JOIN
                fernwood.privilege_grants pgr
                ON pgr.granter_id = mpr.id
                AND pgr.valid_to IS NULL
        JOIN
                fernwood.privilege_sets pse
                ON pse.id = pgr.privilege_set                                                                                                                                          
        WHERE
                s.state IN (2, 4, 7, 8)
                AND
                s.owner_center IN (:Scope)
                AND 
                pse.name NOT IN ('Reciprocal Rights','Gym Access')
        UNION ALL
        SELECT
                c.shortname AS "Club Name"
                ,p.external_id AS "External ID"	
                ,p.center 
                ,p.id
                ,p.fullname AS "Member Full Name"
                ,mobile.txtvalue AS "Contact Number"
                ,email.txtvalue AS "Email"
                ,CASE
                        WHEN p.status = 0 THEN 'Lead'
                        WHEN p.status = 1 THEN 'Active'
                        WHEN p.status = 2 THEN 'Inactive'
                        WHEN p.status = 3 THEN 'Temporary Inactive'
                        WHEN p.status = 4 THEN 'Transfered'
                        WHEN p.status = 5 THEN 'Duplicate'
                        WHEN p.status = 6 THEN 'Prospect'
                        WHEN p.status = 7 THEN 'Deleted'
                        WHEN p.status = 8 THEN 'Anonymized'
                        WHEN p.status = 9 THEN 'Contact'
                        ELSE 'Unknown'
                END AS "Person Status"
                ,CASE 
                        WHEN p.persontype = 0 THEN 'PRIVATE' 
                        WHEN p.persontype = 1 THEN 'STUDENT' 
                        WHEN p.persontype = 2 THEN 'STAFF' 
                        WHEN p.persontype = 3 THEN 'FRIEND' 
                        WHEN p.persontype = 4 THEN 'CORPORATE' 
                        WHEN p.persontype = 5 THEN 'ONEMANCORPORATE' 
                        WHEN p.persontype = 6 THEN 'FAMILY' 
                        WHEN p.persontype = 7 THEN 'SENIOR' 
                        WHEN p.persontype = 8 THEN 'GUEST' 
                        WHEN p.persontype = 9 THEN 'CHILD' 
                        WHEN p.persontype = 10 THEN 'EXTERNAL_STAFF' 
                        ELSE 'Undefined' 
                END AS "Person Type"
                ,prod.name AS "Component"	 
                ,s.start_date AS "Start Date"
                ,s.end_date AS "Stop Date"	
                ,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
                ,'Recurring Clipcard' AS "Type"
                ,pglc.product_group_id AS "Exclude" 
                ,prod.globalid AS "GlobalID"
                ,s.subscription_price AS "Price"                                        
        FROM
                fernwood.subscriptions s        
        JOIN
                fernwood.subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.ID = s.subscriptiontype_id
                AND st.st_type = 2 
        JOIN
                fernwood.products prod
                ON prod.center = st.center
                AND prod.id = st.id
        JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = prod.center  
                AND pgl.product_id = prod.id
        LEFT JOIN
                fernwood.product_and_product_group_link pglc
                ON pglc.product_center = prod.center
                AND pglc.product_id = prod.id
                AND pglc.product_group_id IN (401,224)         
        JOIN
                fernwood.persons p
                ON p.center = s.owner_center
                AND p.id = s.owner_id
                AND p.status NOT IN (2,4,5,7)
        JOIN
                fernwood.centers c
                ON c.id = p.center
        LEFT JOIN
                fernwood.person_ext_attrs mobile
                ON mobile.personcenter = p.center
                AND mobile.personid = p.id
                AND mobile.name = '_eClub_PhoneSMS'
        LEFT JOIN
                fernwood.person_ext_attrs email
                ON email.personcenter = p.center
                AND email.personid = p.id
                AND email.name = '_eClub_Email'
        LEFT JOIN
                (SELECT 
                        max(checkin_time) AS LastVisitDate
                        ,person_center AS PersonCenter
                        ,person_id AS PersonID             
                FROM 
                        fernwood.checkins 
                GROUP BY 
                        person_center
                        ,person_id )la
                ON la.PersonCenter = p.center
                AND la.PersonID = p.id  
                JOIN
                fernwood.masterproductregister mpr
                ON mpr.globalid = prod.globalid
                AND mpr.scope_type = 'A'
        LEFT JOIN
                fernwood.privilege_grants pgr
                ON pgr.granter_id = mpr.id
                AND pgr.valid_to IS NULL
        LEFT JOIN
                fernwood.privilege_sets pse
                ON pse.id = pgr.privilege_set                                                                                                                           
        WHERE
                s.state IN (2, 4, 7, 8)
                AND
                s.owner_center IN (:Scope)
                --AND
                --pse.name NOT IN ('Reciprocal Rights','Gym Access')                        
        UNION ALL
        SELECT DISTINCT
                c.shortname AS"Club Name"
                ,p.external_id AS "External ID"	
                ,p.center 
                ,p.id	
                ,p.fullname AS "Member Full Name"
                ,mobile.txtvalue AS "Contact Number"	
                ,email.txtvalue AS "Email"
                ,CASE
                        WHEN p.status = 0 THEN 'Lead'
                        WHEN p.status = 1 THEN 'Active'
                        WHEN p.status = 2 THEN 'Inactive'
                        WHEN p.status = 3 THEN 'Temporary Inactive'
                        WHEN p.status = 4 THEN 'Transfered'
                        WHEN p.status = 5 THEN 'Duplicate'
                        WHEN p.status = 6 THEN 'Prospect'
                        WHEN p.status = 7 THEN 'Deleted'
                        WHEN p.status = 8 THEN 'Anonymized'
                        WHEN p.status = 9 THEN 'Contact'
                        ELSE 'Unknown'
                END AS "Person Status"	
                ,CASE 
                        WHEN p.persontype = 0 THEN 'PRIVATE' 
                        WHEN p.persontype = 1 THEN 'STUDENT' 
                        WHEN p.persontype = 2 THEN 'STAFF' 
                        WHEN p.persontype = 3 THEN 'FRIEND' 
                        WHEN p.persontype = 4 THEN 'CORPORATE' 
                        WHEN p.persontype = 5 THEN 'ONEMANCORPORATE' 
                        WHEN p.persontype = 6 THEN 'FAMILY' 
                        WHEN p.persontype = 7 THEN 'SENIOR' 
                        WHEN p.persontype = 8 THEN 'GUEST' 
                        WHEN p.persontype = 9 THEN 'CHILD' 
                        WHEN p.persontype = 10 THEN 'EXTERNAL_STAFF' 
                        ELSE 'Undefined' 
                END AS "Person Type"                
                ,prod_addon.name AS "Component"
                ,sao.start_date AS "Start Date"
                ,sao.end_date AS "Stop Date"
                ,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
                ,'Addon' AS "Type"
                ,pglc.product_group_id AS "Exclude"  
                ,prod_addon.globalid AS "GlobalID" 
                ,sao.individual_price_per_unit AS "Price"                                     
        FROM
                fernwood.subscriptions s        
        JOIN
                fernwood.subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.ID = s.subscriptiontype_id
        JOIN
                fernwood.persons p
                ON p.center = s.owner_center
                AND p.id = s.owner_id
                AND p.status NOT IN (2,4,5,7)
        JOIN
                fernwood.centers c
                ON c.id = p.center
        LEFT JOIN
                fernwood.person_ext_attrs mobile
                ON mobile.personcenter = p.center
                AND mobile.personid = p.id
                AND mobile.name = '_eClub_PhoneSMS'
        LEFT JOIN
                fernwood.person_ext_attrs email
                ON email.personcenter = p.center
                AND email.personid = p.id
                AND email.name = '_eClub_Email'
        LEFT JOIN
                (SELECT 
                        max(checkin_time) AS LastVisitDate
                        ,person_center AS PersonCenter
                        ,person_id AS PersonID             
                FROM 
                        fernwood.checkins 
                GROUP BY 
                        person_center
                        ,person_id )la
                ON la.PersonCenter = p.center
                AND la.PersonID = p.id                                                  
        JOIN
                fernwood.subscription_addon sao 
                ON sao.subscription_center = s.center 
                AND sao.subscription_id = s.id
                AND sao.cancelled = 'false'
        JOIN  
                fernwood.MASTERPRODUCTREGISTER mpr_addon 
                ON mpr_addon.id = sao.ADDON_PRODUCT_ID
        JOIN 
                fernwood.PRODUCTS prod_addon
                ON prod_addon.center = sao.CENTER_ID
                AND prod_addon.GLOBALID = mpr_addon.GLOBALID
        JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = prod_addon.center  
                AND pgl.product_id = prod_addon.id
        LEFT JOIN
                fernwood.product_and_product_group_link pglc
                ON pglc.product_center = prod_addon.center
                AND pglc.product_id = prod_addon.id
                AND pglc.product_group_id IN (401,224)
        JOIN
                fernwood.masterproductregister mpr
                ON mpr.globalid = prod_addon.globalid
                AND mpr.scope_type = 'A'
        JOIN
                fernwood.privilege_grants pgr
                ON pgr.granter_id = mpr.id
                AND pgr.valid_to IS NULL
        JOIN
                fernwood.privilege_sets pse
                ON pse.id = pgr.privilege_set                                             
        WHERE
                s.state IN (2, 4, 7, 8)
                AND
                (sao.end_date IS NULL OR sao.end_date >= current_date) 
                AND
                s.owner_center IN (:Scope)
                AND
                pse.name NOT IN ('Reciprocal Rights','Gym Access')                       
        UNION ALL
        SELECT DISTINCT
                c.shortname AS"Club Name"
                ,p.external_id AS "External ID"	
                ,p.center 
                ,p.id	
                ,p.fullname AS "Member Full Name"
                ,mobile.txtvalue AS "Contact Number"	
                ,email.txtvalue AS "Email"
                ,CASE
                        WHEN p.status = 0 THEN 'Lead'
                        WHEN p.status = 1 THEN 'Active'
                        WHEN p.status = 2 THEN 'Inactive'
                        WHEN p.status = 3 THEN 'Temporary Inactive'
                        WHEN p.status = 4 THEN 'Transfered'
                        WHEN p.status = 5 THEN 'Duplicate'
                        WHEN p.status = 6 THEN 'Prospect'
                        WHEN p.status = 7 THEN 'Deleted'
                        WHEN p.status = 8 THEN 'Anonymized'
                        WHEN p.status = 9 THEN 'Contact'
                        ELSE 'Unknown'
                END AS "Person Status"	
                ,CASE 
                        WHEN p.persontype = 0 THEN 'PRIVATE' 
                        WHEN p.persontype = 1 THEN 'STUDENT' 
                        WHEN p.persontype = 2 THEN 'STAFF' 
                        WHEN p.persontype = 3 THEN 'FRIEND' 
                        WHEN p.persontype = 4 THEN 'CORPORATE' 
                        WHEN p.persontype = 5 THEN 'ONEMANCORPORATE' 
                        WHEN p.persontype = 6 THEN 'FAMILY' 
                        WHEN p.persontype = 7 THEN 'SENIOR' 
                        WHEN p.persontype = 8 THEN 'GUEST' 
                        WHEN p.persontype = 9 THEN 'CHILD' 
                        WHEN p.persontype = 10 THEN 'EXTERNAL_STAFF' 
                        ELSE 'Undefined' 
                END AS "Person Type"                
                ,pro.name AS "Component"
                ,(CAST(longtodatec(cc.valid_from,cc.center) as date)) AS "Start Date"
                ,(CAST(longtodatec(cc.valid_until,cc.center) as date)) AS "Stop Date"
                ,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
                ,'Clipcard' AS "Type"
                ,pglc.product_group_id AS "Exclude"
                ,pro.globalid AS "GlobalID"
                ,invl.total_amount AS "Price"
        FROM
                fernwood.subscriptions s        
        JOIN
                fernwood.subscriptiontypes st
                ON st.center = s.subscriptiontype_center
                AND st.ID = s.subscriptiontype_id
        JOIN
                fernwood.persons p
                ON p.center = s.owner_center
                AND p.id = s.owner_id
                AND p.status NOT IN (2,4,5,7)
        JOIN
                fernwood.centers c
                ON c.id = p.center
        LEFT JOIN
                fernwood.person_ext_attrs mobile
                ON mobile.personcenter = p.center
                AND mobile.personid = p.id
                AND mobile.name = '_eClub_PhoneSMS'
        LEFT JOIN
                fernwood.person_ext_attrs email
                ON email.personcenter = p.center
                AND email.personid = p.id
                AND email.name = '_eClub_Email'
        LEFT JOIN
                (SELECT 
                        max(checkin_time) AS LastVisitDate
                        ,person_center AS PersonCenter
                        ,person_id AS PersonID             
                FROM 
                        fernwood.checkins 
                GROUP BY 
                        person_center
                        ,person_id 
                )la
                ON la.PersonCenter = p.center
                AND la.PersonID = p.id                                          
        JOIN
                fernwood.clipcards cc 
                ON cc.owner_center = p.center 
                AND cc.owner_id = p.id
                AND cc.cancelled = 'false' 
                AND cc.finished = 'false' 
                AND cc.blocked = 'false' 
        JOIN 
                fernwood.products pro 
                ON pro.center = cc.center
                AND pro.id = cc.ID
        JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = pro.center  
                AND pgl.product_id = pro.id
        LEFT JOIN
                fernwood.product_and_product_group_link pglc
                ON pglc.product_center = pro.center
                AND pglc.product_id = pro.id
                AND pglc.product_group_id IN (6,401,224)
        JOIN
                fernwood.invoice_lines_mt invl
                ON cc.invoiceline_center = invl.center 
                AND cc.invoiceline_id = invl.id 
                AND cc.invoiceline_subid = invl.subid  
                JOIN
                fernwood.masterproductregister mpr
                ON mpr.globalid = pro.globalid
                AND mpr.scope_type = 'A'
        JOIN
                fernwood.privilege_grants pgr
                ON pgr.granter_id = mpr.id
                AND pgr.valid_to IS NULL
        JOIN
                fernwood.privilege_sets pse
                ON pse.id = pgr.privilege_set                                                                                                                    
        WHERE
                cc.valid_until >= datetolongC(TO_CHAR(CAST(current_date AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) 
                AND
                s.owner_center IN (:Scope)
                AND
                pse.name NOT IN ('Reciprocal Rights','Gym Access')                 
        )t1
WHERE
        t1."Exclude" IS NULL    
        AND
        t1."GlobalID" NOT IN ('REFORMER_PILATES_CHALLENGE','REFORMER_PILATES_REGISTRATION','REFORMER_PILATES_EVENTS','REFORMER_PILATES_INTRO_SESSION','FIIT30_GAMES_PRODUCT','BOXING_1_SESSION','BOXING_10_SESSIONS','FITNESS_COACH_SESSION','PROGRAM_PAID','STAFF_PERSONAL_TRAINING_1')