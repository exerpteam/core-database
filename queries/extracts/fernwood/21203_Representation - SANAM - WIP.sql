WITH
product_group_flags AS
        (
        SELECT
                CASE
                        WHEN pg.id IN (226,214) THEN 'personal_training'
                        WHEN pg.id IN (215) THEN 'FIIT30'
                        WHEN pg.id IN (5801,8002) THEN 'nutrition_coaching'
                        WHEN pg.id IN (217,4802) THEN 'reformer_pilates'
                        WHEN pg.id IN (235) THEN 'hypoxi_'
                        WHEN pg.id IN (2202,224) THEN 'Challenges'
                END AS Product_group
                ,p.center
                ,p.id                
        FROM
                fernwood.products p
        JOIN
                fernwood.product_and_product_group_link pgl
                ON pgl.product_center = p.center
                AND pgl.product_id = p.id
        JOIN        
                fernwood.product_group pg
                ON pg.id = pgl.product_group_id
        WHERE 
                pg.id in (226,214,215,5801,8002,217,4802,235,2202,224)
        ),                
params AS
(
        SELECT
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
                centers c
),
lastattend AS
(
        SELECT
                TO_CHAR(longtodateC(t3.Visit,t3.center),'YYYY-MM-DD') AS "Visit Date" 
                ,t3.center
                ,t3.id
                ,t3.Activity AS ProductGroup  
        FROM
                (
                SELECT
                        max(t2.starttime) AS Visit
                        ,t2.center
                        ,t2.id
                        ,t2.Activity  
                FROM
                                (        
                                SELECT
                                        b.name AS ClassName
                                        ,b.starttime

                                        ,p.center
                                        ,p.id


                                        ,acg.name AS ActivityGroup
                                        ,ac.activity_group_id
                                        ,CASE
                                                WHEN b.activity IN (16,7201,9401,5203) THEN 'FIIT30'
                                                WHEN b.activity IN (13002,15001,13003,15401,13401,15203,15405,14203,13201) THEN 'nutrition_coaching'
                                                WHEN b.activity IN (6,8020,9003,803,3401,9404,9004,8019,3,2,601,9005,8417) THEN 'personal_training'
                                                WHEN b.activity IN (6401,6601,6801,9405,8802,9406,2603,3201,802,3001,1001,1002,17,2006) THEN 'reformer_pilates'
                                                WHEN b.activity IN (10,11,13,14,3402,10601,10801,11203,11604,11605,23401,23402) THEN 'hypoxi_' 
                                        END AS Activity                                                    
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
                                        AND b.activity IN (16,7201,9401,5203,13002,15001,13003,15401,13401,15203,15405,14203,13201,6,8020,9003,803,3401,9404,9004,8019,3,2,601,9005,8417,6401,6601,6801,9405,8802,9406,2603,3201,802,3001,1001,1002,17,2006,10,11,13,14,3402,10601,10801,11203,11604,11605,23401,23402)
                                JOIN 
                                        fernwood.activity ac
                                        ON b.activity = ac.id                        
                                JOIN 
                                        fernwood.activity_group acg
                                        ON acg.id = ac.activity_group_id               
                                 WHERE
                                        part.state != 'CANCELLED'
                                        AND
                                        b.starttime < FLOOR(extract(epoch from now())*1000)
                                        AND
                                        p.center in (:Scope)
                                )t2
                GROUP BY 
                        t2.center
                        ,t2.id
                        ,t2.Activity 
                )t3
)                        
--SELECT DISTINCT
--        t.name AS "Club Name"
--        ,t."Member Full Name"
--        ,t.center||'p'||t.id AS "Person ID"
--        ,t."Mobile Number"
--        ,t."Email Address"
--        ,t."Service Purchased"
--	,t."Purchase Date"
--        ,t.GrossValue AS "Gross Value"
--        ,t."Staff Member"
--        ,t."Sold on behalf of"
--        ,t."First Purchase"
--        ,t."Last attended Session"
--        ,t."Instalment Plan"
--		,CASE t.status 
--                WHEN 0 THEN 'LEAD' 
--                WHEN 1 THEN 'ACTIVE' 
--                WHEN 2 THEN 'INACTIVE' 
--                WHEN 3 THEN 'TEMPORARYINACTIVE' 
--                WHEN 4 THEN 'TRANSFERRED' 
--                WHEN 5 THEN 'DUPLICATE' 
--                WHEN 6 THEN 'PROSPECT' 
--                WHEN 7 THEN 'DELETED' 
--                WHEN 8 THEN 'ANONYMIZED' 
--                WHEN 9 THEN 'CONTACT' 
--                ELSE 'Undefined' 
--        END AS "Person Status"
--        ,t.type
--        ,t.external_id
--        --,t.productgroup
--FROM
--        (
--        SELECT
--                t1.*
--                ,CASE
--                        WHEN ip.id IS NOT NULL THEN 'Yes'
--                        ELSE 'No'
--                END AS  "Instalment Plan" 
--                ,lastattend."Visit Date" AS "Last attended Session"
--                ,CASE
--                        WHEN (count(*) OVER (PARTITION BY t1.center, t1.id, t1.productgroup))> 1 THEN 'No'
--                        ELSE 'Yes'
--                END AS "First Purchase" 
--        FROM
--                        (
--                        SELECT
--                                t1."Member Full Name"
--                                ,t1.center
--                                ,t1.id
--                                ,t1."Mobile Number"
--                                ,t1."Email Address"
--                                ,t1."Service Purchased"
--                                ,t1."Purchase Date"
--                                ,t1."Staff Member"
--                                ,t1."Sold on behalf of"
--                                ,STRING_AGG(t1.product_group, '') AS productgroup
--                                ,t1.name
--                                ,t1.GrossValue
--                                ,t1.status
--                                ,t1.BindingPeriod
--                                ,t1.type
--                                ,t1.external_id
--                        FROM
--                        (
--                                SELECT 
--                                        t1."Member Full Name"
--                                        ,t1.center
--                                        ,t1.id
--                                        ,t1."Mobile Number"
--                                        ,t1."Email Address"
--                                        ,t1."Service Purchased"
--                                        ,t1."Purchase Date"
--                                        ,t1."Staff Member"
--                                        ,t1."Sold on behalf of"
--                                        ,t1.product_group                                        
--                                        ,t1.name
--                                        ,SUM(t1.GrossValue) AS GrossValue
--                                        ,t1.status
--                                        ,t1.BindingPeriod
--                                        ,t1.type
--                                        ,t1.external_id
--                                FROM
--                                        (
--                                                        --------EFT subscriptions---------
--                                                        SELECT
--                                                                p.fullname AS "Member Full Name"
--                                                                ,p.center
--                                                                ,p.id
--                                                                ,peaMobile.txtvalue AS "Mobile Number"
--                                                                ,peaEmail.txtvalue AS "Email Address"
--                                                                ,prod.name AS "Service Purchased"
--                                                                ,CAST(longtodateC(s.creation_time,s.center) as date) AS "Purchase Date"
--                                                                ,pemp.fullname || ' (' || emp.center || 'emp' || emp.id || ')' AS "Staff Member"
--                                                                ,pemps.fullname || ' (' || emps.center || 'emp' || emps.id || ')' AS "Sold on behalf of"
--                                                                ,CASE
--                                                                        WHEN pgf.product_group = 'Challenges' THEN ''
--                                                                        ELSE pgf.product_group
--                                                                END AS product_group                                        
--                                                                ,c.name
--                                                                ,CASE
--                                                                        WHEN pgf.product_group = 'hypoxi_' THEN
--                                                                                CASE
--                                                                                        WHEN st.bindingperiodcount = 2 THEN ss.price_period * 2 
--                                                                                        ELSE (ss.price_period * st.bindingperiodcount / 2)
--                                                                                END 
--                                                                        ELSE
--                                                                                CASE
--                                                                                        WHEN st.bindingperiodcount = 2 THEN ss.price_period * 6 
--                                                                                        ELSE (ss.price_period * st.bindingperiodcount / 2) 
--                                                                                END
--                                                                END AS GrossValue
--                                                                ,p.status
--                                                                ,st.bindingperiodcount AS BindingPeriod
--                                                                ,'EFT' AS type
--                                                                ,p.external_id
--                                                                ,1 as subid
--                                                        FROM
--                                                                fernwood.subscription_sales ss
--                                                        JOIN
--                                                                fernwood.subscriptions s
--                                                                ON s.center = ss.SUBSCRIPTION_CENTER
--                                                                AND s.id = ss.SUBSCRIPTION_ID
--                                                                AND s.state != 5
--                                                                AND s.sub_state not in (8,7)
--                                                        JOIN
--                                                                fernwood.subscriptiontypes st
--                                                                ON s.subscriptiontype_center = st.center
--                                                                AND s.subscriptiontype_id = st.id
--                                                                AND st.st_type = 1
--                                                        JOIN
--                                                                fernwood.products prod
--                                                                ON prod.center = st.center
--                                                                AND prod.id = st.id 
--                                                        JOIN
--                                                                product_group_flags pgf
--                                                                ON pgf.center = prod.center
--                                                                AND pgf.id = prod.id
--                                                        JOIN 
--                                                                params 
--                                                                ON params.CENTER_ID = s.center
--                                                        JOIN
--                                                                fernwood.centers c
--                                                                ON c.id = s.center
--                                                        JOIN
--                                                                fernwood.persons p
--                                                                ON p.center = s.owner_center
--                                                                AND p.id = s.owner_id
--                                                        LEFT JOIN
--                                                                fernwood.person_ext_attrs peaMobile
--                                                                ON peaMobile.personcenter = p.center
--                                                                AND peaMobile.personid = p.id
--                                                                AND peaMobile.name = '_eClub_PhoneSMS' 
--                                                        LEFT JOIN
--                                                                fernwood.person_ext_attrs peaEmail
--                                                                ON peaEmail.personcenter = p.center
--                                                                AND peaEmail.personid = p.id
--                                                                AND peaEmail.name = '_eClub_Email'
--                                                        JOIN
--                                                                fernwood.employees emp
--                                                                ON emp.center = s.creator_center
--                                                                AND emp.id = s.creator_id
--                                                        JOIN
--                                                                fernwood.persons pemp
--                                                                ON pemp.center = emp.personcenter
--                                                                AND pemp.id = emp.personid
--                                                        LEFT JOIN     
--                                                                fernwood.employees emps
--                                                                ON emps.center = ss.employee_center
--                                                                AND emps.id = ss.employee_id
--                                                        LEFT JOIN
--                                                                fernwood.persons pemps
--                                                                ON pemps.CENTER = emps.PERSONCENTER
--                                                                AND pemps.ID = emps.PERSONID                                                                                                        
--                                                        WHERE
--                                                                s.creation_time BETWEEN params.FromDate AND params.ToDate
--                                                                AND
--                                                                s.center IN (:Scope)
--                                                                AND 
--                                                                pgf.product_group IN (:Product_group)
--                                                        UNION ALL
                                                        --------Recurring clipcard subscriptions---------
                                                        SELECT
                                                                p.fullname AS "Member Full Name"
                                                                ,p.center
                                                                ,p.id
                                                                ,peaMobile.txtvalue AS "Mobile Number"
                                                                ,peaEmail.txtvalue AS "Email Address"
                                                                ,prod.name AS "Service Purchased"
                                                                ,CAST(longtodateC(s.creation_time,s.center) as date) AS "Purchase Date"
                                                                ,pemp.fullname || ' (' || emp.center || 'emp' || emp.id || ')' AS "Staff Member"
                                                                ,pemps.fullname || ' (' || emps.center || 'emp' || emps.id || ')' AS "Sold on behalf of"
                                                                ,CASE
                                                                        WHEN pgf.product_group = 'Challenges' THEN ''
                                                                        ELSE pgf.product_group
                                                                END AS product_group 
                                                                ,c.name
                                                                ,CASE
                                                                        WHEN pgf.product_group = 'hypoxi_' THEN
                                                                                CASE
                                                                                        WHEN st.bindingperiodcount IS NULL THEN 
                                                                                                CASE
                                                                                                        WHEN LOWER(prod.name) LIKE '%4 week%' THEN (ss.price_period * 2 ) + COALESCE(su.total_amount, 0)
                                                                                                        WHEN LOWER(prod.name) LIKE '%6 week%' THEN (ss.price_period * 3 ) + COALESCE(su.total_amount, 0)
                                                                                                        WHEN LOWER(prod.name) LIKE '%8 week%' THEN (ss.price_period * 4 ) + COALESCE(su.total_amount, 0)
                                                                                                        WHEN LOWER(prod.name) LIKE '%12 week%' THEN (ss.price_period * 6 ) + COALESCE(su.total_amount, 0)
                                                                                                        WHEN LOWER(prod.name) LIKE '%26 week%' THEN (ss.price_period * 12 ) + COALESCE(su.total_amount, 0)
                                                                                                END                                                                                                        
                                                                                        WHEN st.bindingperiodcount = 2 THEN (ss.price_period * 2 ) + COALESCE(su.total_amount, 0)
                                                                                        ELSE (ss.price_period * st.bindingperiodcount / 2) + COALESCE(su.total_amount, 0)
                                                                                        
                                                                                END 
                                                                        ELSE
                                                                                CASE
                                                                                        WHEN st.bindingperiodcount = 2 THEN (ss.price_period * 6 ) + COALESCE(su.total_amount, 0)
                                                                                        ELSE (ss.price_period * st.bindingperiodcount / 2) + COALESCE(su.total_amount, 0) 
                                                                                END
                                                                END AS GrossValue
                                                                ,ss.price_period
                                                                ,su.total_amount
                                                                ,p.status
                                                                ,st.bindingperiodcount AS BindingPeriod
                                                                ,'recurringclipcard' AS type
                                                                ,p.external_id
                                                                ,1 as subid
                                                        FROM
                                                                fernwood.subscription_sales ss
                                                        JOIN
                                                                fernwood.subscriptions s
                                                                ON s.center = ss.SUBSCRIPTION_CENTER
                                                                AND s.id = ss.SUBSCRIPTION_ID
                                                                AND s.state != 5
                                                                AND s.sub_state != 8
                                                        JOIN
                                                                fernwood.subscriptiontypes st
                                                                ON s.subscriptiontype_center = st.center
                                                                AND s.subscriptiontype_id = st.id
                                                                AND st.st_type = 2
                                                        JOIN
                                                                fernwood.products prod
                                                                ON prod.center = st.center
                                                                AND prod.id = st.id 
                                                        JOIN
                                                                product_group_flags pgf
                                                                ON pgf.center = prod.center
                                                                AND pgf.id = prod.id
                                                        JOIN 
                                                                params 
                                                                ON params.CENTER_ID = s.center
                                                        JOIN
                                                                fernwood.centers c
                                                                ON c.id = s.center
                                                        JOIN
                                                                fernwood.persons p
                                                                ON p.center = s.owner_center
                                                                AND p.id = s.owner_id
                                                        LEFT JOIN
                                                                fernwood.person_ext_attrs peaMobile
                                                                ON peaMobile.personcenter = p.center
                                                                AND peaMobile.personid = p.id
                                                                AND peaMobile.name = '_eClub_PhoneSMS' 
                                                        LEFT JOIN
                                                                fernwood.person_ext_attrs peaEmail
                                                                ON peaEmail.personcenter = p.center
                                                                AND peaEmail.personid = p.id
                                                                AND peaEmail.name = '_eClub_Email'
                                                        JOIN
                                                                fernwood.employees emp
                                                                ON emp.center = s.creator_center
                                                                AND emp.id = s.creator_id
                                                        JOIN
                                                                fernwood.persons pemp
                                                                ON pemp.center = emp.personcenter
                                                                AND pemp.id = emp.personid
                                                        LEFT JOIN     
                                                                fernwood.employees emps
                                                                ON emps.center = ss.employee_center
                                                                AND emps.id = ss.employee_id
                                                        LEFT JOIN
                                                                fernwood.persons pemps
                                                                ON pemps.CENTER = emps.PERSONCENTER
                                                                AND pemps.ID = emps.PERSONID  
                                                        LEFT JOIN
                                                                (
                                                                SELECT 
                                                                        s.center
                                                                        ,s.id
                                                                        ,inl.total_amount
                                                                FROM 
                                                                        fernwood.subscriptions s
                                                                JOIN
                                                                        fernwood.invoice_lines_mt inl
                                                                        ON inl.center = s.invoiceline_center
                                                                        AND inl.id = s.invoiceline_id
                                                                        AND inl.subid = s.invoiceline_subid
                                                                )su
                                                                ON su.center = s.center
                                                                AND su.id = s.id  
                                                        LEFT JOIN
                                                                fernwood.subscriptions schange
                                                                ON schange.changed_to_center = s.center
                                                                AND schange.changed_to_id = s.id
                                                                AND schange.change_type = 13                                                                                                     
                                                        WHERE
                                                                s.creation_time BETWEEN params.FromDate AND params.ToDate
                                                                AND
                                                                s.center IN (:Scope)
                                                                AND 
                                                                pgf.product_group IN (:Product_group)
                                                                AND
                                                                schange.center IS NULL
                                                            
