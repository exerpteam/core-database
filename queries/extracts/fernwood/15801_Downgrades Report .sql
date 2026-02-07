SELECT
        t1."Club Name"
        ,t1."External ID"	
        ,t1."Person ID"	
        ,t1."Member Full Name"
        ,t1."Contact Number"	
        ,t1."Email"
        ,t1."Person Status"	
        ,t1."Membership Subscription"
        ,t1."Last Visit Date"        
        ,t1."rcc-Downgrade Component" AS "Recurring Clipcard"
        ,t1."rcc-Start Date" AS "Recurring Clipcard Start Date"
        ,t1."rcc-Stop Date" AS "Recurring Clipcard Stop Date"
        ,t1."sao-Downgrade Component" AS "Subscription Addon"
        ,t1."sao-Start Date" AS "Subscription Addon Start Date"
        ,t1."sao-Stop Date" AS "Subscription Addon Stop Date"
        ,t1."cc-Downgrade Component" AS "Clipcard"
        ,t1."cc-Start Date" AS "Clipcard Start Date"
        ,t1."cc-Stop Date" AS "Clipcard Stop Date"
FROM
        (
        WITH
          params AS
          (
              SELECT
                  /*+ materialize */
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDateLong,
                CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDateLong,
                CAST(:From AS DATE) AS FromDate,
                CAST(:To AS DATE) + INTERVAL '1 day' AS ToDate,
                c.id AS CENTER_ID                  
              FROM
                  centers c
         ),
         last_checkin AS
         (
                SELECT 
                        max(checkin_time) AS LastVisitDate
                        ,person_center AS PersonCenter
                        ,person_id AS PersonID             
                FROM 
                        fernwood.checkins 
                GROUP BY 
                        person_center
                        ,person_id 
        ),
        recurring_clipcard AS
        (
                SELECT
                        s.owner_center
                        ,s.owner_id
                        ,s.center
                        ,s.id
                        ,s.start_date
                        ,s.end_date
                        ,prod.name
                        ,'RecurringClipcard' AS ServiceType
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
                        params
                        ON params.center_id = s.center                        
                WHERE
                        s.end_date BETWEEN params.FromDate AND params.ToDate 
        ),
        subscription_addon AS
        (
                SELECT
                        sao.subscription_center
                        ,sao.subscription_id
                        ,sao.start_date
                        ,sao.end_date
                        ,prod_addon.name
                        ,'Addon' AS ServiceType
                FROM
                        fernwood.subscription_addon sao 
                JOIN  
                        fernwood.masterproductregister mpr_addon 
                        ON mpr_addon.id = sao.addon_product_id
                JOIN 
                        fernwood.products prod_addon
                        ON prod_addon.center = sao.center_id
                        AND prod_addon.globalid = mpr_addon.globalid
                JOIN
                        params 
                        ON params.center_id = sao.subscription_center 
                LEFT JOIN
                        fernwood.product_and_product_group_link pglc
                        ON pglc.product_center = prod_addon.center
                        AND pglc.product_id = prod_addon.id
                        AND pglc.product_group_id = 401                        
                WHERE
                        sao.cancelled = 'false'
                        AND
                        sao.end_date BETWEEN params.FromDate AND params.ToDate
                        AND
                        pglc.product_group_id IS NULL                                                                         
                ),
        clipcard AS
        (
                SELECT
                        cc.owner_center
                        ,cc.owner_id
                        ,pro.name
                        ,cc.valid_until
                        ,cc.valid_from
                        ,'Clipcard' AS ServiceType
                FROM
                        fernwood.clipcards cc 
                JOIN 
                        fernwood.products pro 
                        ON pro.center = cc.center
                        AND pro.id = cc.ID
                LEFT JOIN
                        fernwood.product_and_product_group_link pglc
                        ON pglc.product_center = pro.center
                        AND pglc.product_id = pro.id
                        AND pglc.product_group_id in (6,225,401)
                JOIN 
                        params 
                        ON params.CENTER_ID = cc.center                                                                   
                WHERE
                        cc.cancelled = 'false' 
                        AND 
                        cc.blocked = 'false' 
                        AND
                        cc.valid_until BETWEEN params.FromDateLong AND params.ToDateLong
                        AND
                        pglc.product_group_id IS NULL
        )                                         
        SELECT DISTINCT
                c.shortname AS"Club Name"
                ,p.external_id AS "External ID"	
                ,p.center ||'p'|| p.id AS "Person ID"	
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
                ,(CAST(longtodatec(la.LastVisitDate,la.PersonCenter) as date)) AS "Last Visit Date"
                ,prod.name AS "Membership Subscription"
                ,rcc.name AS "rcc-Downgrade Component"
                ,rcc.start_date AS "rcc-Start Date"
                ,rcc.end_date AS "rcc-Stop Date"
                ,cc.name AS "cc-Downgrade Component"
                ,longtodatec(cc.valid_from,cc.owner_center) AS "cc-Start Date"
                ,longtodatec(cc.valid_until,cc.owner_center) AS "cc-Stop Date"
                ,sao.name AS "sao-Downgrade Component"
                ,sao.start_date AS "sao-Start Date"
                ,sao.end_date AS "sao-Stop Date"
                ,CASE
                        WHEN sao.ServiceType IS NOT NULL THEN 'DD'
                        WHEN cc.ServiceType IS NOT NULL THEN 'Pack'
                        WHEN rcc.ServiceType IS NOT NULL THEN 'DD'
                END AS ServiceType                        
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
                AND pgl.product_group_id = 5601 
        JOIN
                fernwood.persons p
                ON p.center = s.owner_center
                AND p.id = s.owner_id
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
                last_checkin la
                ON la.PersonCenter = p.center
                AND la.PersonID = p.id                                          
        LEFT JOIN
                recurring_clipcard rcc
                ON rcc.owner_center = p.center
                AND rcc.owner_id = p.id
        LEFT JOIN
                subscription_addon sao
                ON sao.subscription_center = s.center
                AND sao.subscription_id = s.id 
        LEFT JOIN
                clipcard cc
                ON cc.owner_center = p.center
                AND cc.owner_id = p.id
        WHERE
                s.state IN (2, 4, 7, 8)
                AND
                s.owner_center IN (:Scope)
                 
        )t1
WHERE
        (
        t1."rcc-Downgrade Component" IS NOT NULL
        OR
        t1."sao-Downgrade Component" IS NOT NULL
        OR
        t1."cc-Downgrade Component" IS NOT NULL
        )
        AND
        t1.ServiceType IN (:ServiceType)                                  
                   