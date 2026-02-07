WITH
product_group_flags AS
        (
        SELECT
                CASE
                        WHEN pg.id IN (235) THEN 'hypoxi_'
                        WHEN pg.id IN (22801) THEN 'hypoxi_members'
                END AS Product_group
                ,p.center
                ,p.id                
        FROM
                products p
        JOIN
                product_and_product_group_link pgl
                ON pgl.product_center = p.center
                AND pgl.product_id = p.id
        JOIN        
                product_group pg
                ON pg.id = pgl.product_group_id
        WHERE 
                pg.id in (235,22801)
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
                                                WHEN b.activity IN (10,11,13,14,3402,10601,10801,11203,11604,11605,23401,23402) THEN 'hypoxi_' 
                                        END AS Activity                                                    
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
                                        AND b.activity IN (10,11,13,14,3402,10601,10801,11203,11604,11605,23401,23402)
                                JOIN 
                                        activity ac
                                        ON b.activity = ac.id                        
                                JOIN 
                                        activity_group acg
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
SELECT DISTINCT
        t.name AS "Club Name"
        ,t."Member Full Name"
        ,t.center||'p'||t.id AS "Person ID"
        ,t."Mobile Number"
        ,t."Email Address"
        ,t."Service Purchased"
        ,t.productgroup AS "Product Group"
	,t."Purchase Date"
        ,t.GrossValue AS "Gross Value"
        ,t."Staff Member"
        ,t."Sold on behalf of"
        ,t."First Purchase"
        ,t."Last attended Session"
        ,t."Instalment Plan"
		,CASE t.status 
                WHEN 0 THEN 'LEAD' 
                WHEN 1 THEN 'ACTIVE' 
                WHEN 2 THEN 'INACTIVE' 
                WHEN 3 THEN 'TEMPORARYINACTIVE' 
                WHEN 4 THEN 'TRANSFERRED' 
                WHEN 5 THEN 'DUPLICATE' 
                WHEN 6 THEN 'PROSPECT' 
                WHEN 7 THEN 'DELETED' 
                WHEN 8 THEN 'ANONYMIZED' 
                WHEN 9 THEN 'CONTACT' 
                ELSE 'Undefined' 
        END AS "Person Status"
        ,t.type
        ,t.external_id
FROM
        (
        SELECT
                t1.*
                ,CASE
                        WHEN ip.id IS NOT NULL THEN 'Yes'
                        ELSE 'No'
                END AS  "Instalment Plan" 
                ,lastattend."Visit Date" AS "Last attended Session"
                ,CASE
                        WHEN (count(*) OVER (PARTITION BY t1.center, t1.id, t1.productgroup))> 1 THEN 'No'
                        ELSE 'Yes'
                END AS "First Purchase" 
        FROM
                        (
                        SELECT
                                t1."Member Full Name"
                                ,t1.center
                                ,t1.id
                                ,t1."Mobile Number"
                                ,t1."Email Address"
                                ,t1."Service Purchased"
                                ,t1."Purchase Date"
                                ,t1."Staff Member"
                                ,t1."Sold on behalf of"
                                ,t1.product_group AS productgroup
                                ,t1.name
                                ,t1.GrossValue
                                ,t1.status
                                ,t1.BindingPeriod
                                ,t1.type
                                ,t1.external_id
                        FROM
                        (
                                SELECT 
                                        t1."Member Full Name"
                                        ,t1.center
                                        ,t1.id
                                        ,t1."Mobile Number"
                                        ,t1."Email Address"
                                        ,t1."Service Purchased"
                                        ,t1."Purchase Date"
                                        ,t1."Staff Member"
                                        ,t1."Sold on behalf of"
                                        ,t1.product_group                                        
                                        ,t1.name
                                        ,SUM(t1.GrossValue) AS GrossValue
                                        ,t1.status
                                        ,t1.BindingPeriod
                                        ,t1.type
                                        ,t1.external_id
                                FROM
                                        (
                                                        --------EFT subscriptions---------
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
                                                                ,pgf.product_group AS product_group                                        
                                                                ,c.name
                                                                ,CASE
                                                                        WHEN pgf.product_group = 'hypoxi_' THEN
                                                                                CASE
                                                                                        WHEN st.bindingperiodcount = 2 THEN ss.price_period * 2 
                                                                                        ELSE (ss.price_period * st.bindingperiodcount / 2)
                                                                                END 
                                                                        WHEN pgf.product_group = 'hypoxi_members' THEN
                                                                                CASE
                                                                                        WHEN st.bindingperiodcount = 2 THEN ss.price_period * 2 
                                                                                        ELSE (ss.price_period * st.bindingperiodcount / 2)
                                                                                END
                                                                        ELSE
                                                                                CASE
                                                                                        WHEN st.bindingperiodcount = 2 THEN ss.price_period * 6 
                                                                                        ELSE (ss.price_period * st.bindingperiodcount / 2) 
                                                                                END
                                                                END AS GrossValue
                                                                ,p.status
                                                                ,st.bindingperiodcount AS BindingPeriod
                                                                ,'EFT' AS type
                                                                ,p.external_id
                                                                ,1 as subid
                                                        FROM
                                                                subscription_sales ss
                                                        JOIN
                                                                subscriptions s
                                                                ON s.center = ss.SUBSCRIPTION_CENTER
                                                                AND s.id = ss.SUBSCRIPTION_ID
                                                                AND s.state != 5
                                                                AND s.sub_state not in (8,7)
                                                        JOIN
                                                                subscriptiontypes st
                                                                ON s.subscriptiontype_center = st.center
                                                                AND s.subscriptiontype_id = st.id
                                                                AND st.st_type = 1
                                                        JOIN
                                                                products prod
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
                                                                centers c
                                                                ON c.id = s.center
                                                        JOIN
                                                                persons p
                                                                ON p.center = s.owner_center
                                                                AND p.id = s.owner_id
                                                        LEFT JOIN
                                                                person_ext_attrs peaMobile
                                                                ON peaMobile.personcenter = p.center
                                                                AND peaMobile.personid = p.id
                                                                AND peaMobile.name = '_eClub_PhoneSMS' 
                                                        LEFT JOIN
                                                                person_ext_attrs peaEmail
                                                                ON peaEmail.personcenter = p.center
                                                                AND peaEmail.personid = p.id
                                                                AND peaEmail.name = '_eClub_Email'
                                                        JOIN
                                                                employees emp
                                                                ON emp.center = s.creator_center
                                                                AND emp.id = s.creator_id
                                                        JOIN
                                                                persons pemp
                                                                ON pemp.center = emp.personcenter
                                                                AND pemp.id = emp.personid
                                                        LEFT JOIN     
                                                                employees emps
                                                                ON emps.center = ss.employee_center
                                                                AND emps.id = ss.employee_id
                                                        LEFT JOIN
                                                                persons pemps
                                                                ON pemps.CENTER = emps.PERSONCENTER
                                                                AND pemps.ID = emps.PERSONID                                                                                                        
                                                        WHERE
                                                                s.creation_time BETWEEN params.FromDate AND params.ToDate
                                                                AND
                                                                s.center IN (:Scope)
                                                        UNION ALL
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
                                                                ,pgf.product_group AS product_group 
                                                                ,c.name
                                                                ,CASE
                                                                        WHEN pgf.product_group IN ('hypoxi_','hypoxi_members') THEN
                                                                                CASE
                                                                                        WHEN st.bindingperiodcount IS NULL THEN 
                                                                                                CASE
                                                                                                        WHEN LOWER(prod.name) LIKE '% 4 week%' THEN (ss.price_period * 2 ) + COALESCE(su.total_amount, 0)
                                                                                                        WHEN LOWER(prod.name) LIKE '% 6 week%' THEN (ss.price_period * 3 ) + COALESCE(su.total_amount, 0)
                                                                                                        WHEN LOWER(prod.name) LIKE '% 8 week%' THEN (ss.price_period * 4 ) + COALESCE(su.total_amount, 0)
                                                                                                        WHEN LOWER(prod.name) LIKE '% 12 week%' THEN (ss.price_period * 6 ) + COALESCE(su.total_amount, 0)
                                                                                                        WHEN LOWER(prod.name) LIKE '% 26 week%' THEN (ss.price_period * 13 ) + COALESCE(su.total_amount, 0)
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
                                                                ,p.status
                                                                ,st.bindingperiodcount AS BindingPeriod
                                                                ,'recurringclipcard' AS type
                                                                ,p.external_id
                                                                ,1 as subid
                                                        FROM
                                                                subscription_sales ss
                                                        JOIN
                                                                subscriptions s
                                                                ON s.center = ss.SUBSCRIPTION_CENTER
                                                                AND s.id = ss.SUBSCRIPTION_ID
                                                                AND s.state != 5
                                                                AND s.sub_state != 8
                                                        JOIN
                                                                subscriptiontypes st
                                                                ON s.subscriptiontype_center = st.center
                                                                AND s.subscriptiontype_id = st.id
                                                                AND st.st_type = 2
                                                        JOIN
                                                                products prod
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
                                                                centers c
                                                                ON c.id = s.center
                                                        JOIN
                                                                persons p
                                                                ON p.center = s.owner_center
                                                                AND p.id = s.owner_id
                                                        LEFT JOIN
                                                                person_ext_attrs peaMobile
                                                                ON peaMobile.personcenter = p.center
                                                                AND peaMobile.personid = p.id
                                                                AND peaMobile.name = '_eClub_PhoneSMS' 
                                                        LEFT JOIN
                                                                person_ext_attrs peaEmail
                                                                ON peaEmail.personcenter = p.center
                                                                AND peaEmail.personid = p.id
                                                                AND peaEmail.name = '_eClub_Email'
                                                        JOIN
                                                                employees emp
                                                                ON emp.center = s.creator_center
                                                                AND emp.id = s.creator_id
                                                        JOIN
                                                                persons pemp
                                                                ON pemp.center = emp.personcenter
                                                                AND pemp.id = emp.personid
                                                        LEFT JOIN     
                                                                employees emps
                                                                ON emps.center = ss.employee_center
                                                                AND emps.id = ss.employee_id
                                                        LEFT JOIN
                                                                persons pemps
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
                                                                schange.center IS NULL
                                                        UNION ALL
                                                        --------Subscription addon---------
                                                        SELECT DISTINCT
                                                                p.fullname AS "Member Full Name"
                                                                ,p.center
                                                                ,p.id
                                                                ,peaMobile.txtvalue AS "Mobile Number"
                                                                ,peaEmail.txtvalue AS "Email Address"
                                                                ,prod.name AS "Service Purchased"
                                                                ,CAST(longtodateC(sao.creation_time,sao.center_id) as date) AS "Purchase Date"
                                                                ,pemp.fullname || ' (' || emp.center || 'emp' || emp.id || ')' AS "Staff Member"
                                                                ,'' AS "Sold on behalf of"
                                                                ,pgf.product_group AS product_group 
                                                                ,c.name
                                                                ,CASE
                                                                        WHEN pgf.product_group IN ('hypoxi_','hypoxi_members') THEN
                                                                                CASE
                                                                                        WHEN aop.binding_period_count IS NULL THEN (sao.individual_price_per_unit * 2 + COALESCE(il.total_amount,0)) 
                                                                                        ELSE ((sao.individual_price_per_unit * aop.binding_period_count / 2)  + COALESCE(il.total_amount,0))
                                                                                END 
                                                                        ELSE
                                                                                CASE
                                                                                        WHEN aop.binding_period_count IS NULL THEN (sao.individual_price_per_unit * 6 + COALESCE(il.total_amount,0)) 
                                                                                        ELSE ((sao.individual_price_per_unit * aop.binding_period_count / 2)  + COALESCE(il.total_amount,0))
                                                                                END
                                                                END AS GrossValue 
                                                                ,p.status                                     
                                                                ,st.bindingperiodcount AS BindingPeriod
                                                                ,'subaddon' AS type
                                                                ,p.external_id
                                                                ,sao.id as subid
                                                        FROM
                                                                subscription_addon sao
                                                        JOIN       
                                                                subscriptions s
                                                                ON sao.subscription_center = s.center 
                                                                AND sao.subscription_id = s.id
                                                                AND s.state != 5 
                                                                AND s.sub_state != 8
                                                        JOIN
                                                                subscriptiontypes st
                                                                ON s.subscriptiontype_center = st.center
                                                                AND s.subscriptiontype_id = st.id  
                                                                AND st.st_type = 1                                         
                                                        JOIN
                                                                persons p
                                                                ON p.center = s.owner_center
                                                                AND p.id = s.owner_id
                                                        LEFT JOIN
                                                                person_ext_attrs peaMobile
                                                                ON peaMobile.personcenter = p.center
                                                                AND peaMobile.personid = p.id
                                                                AND peaMobile.name = '_eClub_PhoneSMS'
                                                        LEFT JOIN
                                                                person_ext_attrs peaEmail
                                                                ON peaEmail.personcenter = p.center
                                                                AND peaEmail.personid = p.id
                                                                AND peaEmail.name = '_eClub_Email' 
                                                        JOIN  
                                                                masterproductregister mpr_addon 
                                                                ON mpr_addon.id = sao.addon_product_id
                                                        JOIN 
                                                                products prod
                                                                ON prod.center = sao.center_id
                                                                AND prod.globalid = mpr_addon.globalid       
                                                        JOIN
                                                                product_group_flags pgf
                                                                ON pgf.center = prod.center
                                                                AND pgf.id = prod.id        
                                                        JOIN
                                                                employees emp
                                                                ON emp.center = sao.employee_creator_center
                                                                AND emp.id = sao.employee_creator_id
                                                        JOIN
                                                                persons pemp
                                                                ON pemp.center = emp.personcenter
                                                                AND pemp.id = emp.personid  
                                                        JOIN 
                                                                params 
                                                                ON params.CENTER_ID = p.center                                          
                                                        JOIN
                                                                fernwood.centers c
                                                                ON c.id = p.center 
                                                        JOIN
                                                                fernwood.subscriptionperiodparts spp
                                                                ON spp.center = s.center
                                                                AND spp.id = s.id
                                                                AND spp.spp_state = 1
                                                                AND spp.spp_type = 1
                                                        JOIN       
                                                                spp_invoicelines_link sil 
                                                                ON spp.center = sil.period_center 
                                                                AND spp.id = sil.period_id 
                                                                AND spp.subid = sil.period_subid
                                                        LEFT JOIN
                                                                invoice_lines_mt il                                
                                                                ON sil.invoiceline_center = il.center 
                                                                AND sil.invoiceline_id = il.id 
                                                                AND sil.invoiceline_subid = il.subid
                                                                AND il.reason = 30
                                                                AND il.productcenter = prod.center
                                                                AND il.productid = prod.id                                                                                      
                                                        LEFT JOIN
                                                                invoices i
                                                                ON i.center = il.center 
                                                                AND i.id = il.id 
                                                        JOIN
                                                                add_on_product_definition aop
                                                                ON aop.id = sao.addon_product_id                                                            
                                                        WHERE 
                                                                sao.cancelled = 'false'
                                                                AND
                                                                sao.creation_time BETWEEN params.FromDate AND params.ToDate 
                                                                AND 
                                                                p.center IN (:Scope)
                                                        UNION ALL
                                                        --------Clipcards---------
                                                        SELECT DISTINCT
                                                                p.fullname AS "Full Name"
                                                                ,p.center 
                                                                ,p.id
                                                                ,peaMobile.txtvalue AS "Mobile Number"
                                                                ,peaEmail.txtvalue AS "Email Address"
                                                                ,prod.name AS "Service Purchased"
                                                                ,CAST(longtodateC(inv.trans_time,inv.center) as date) AS "Purchase Date"
                                                                ,pemp.fullname || ' (' || emp.center || 'emp' || emp.id || ')' AS "Staff Member"
                                                                ,pemps.fullname || ' (' || emps.center || 'emp' || emps.id || ')' AS "Sold on behalf of"
                                                                ,pgf.product_group AS product_group 
                                                                ,c.name
                                                                ,invl.total_amount AS GrossValue
                                                                ,p.status
                                                                ,1 AS BindingPeriod
                                                                ,'Clipcard' AS type
                                                                ,p.external_id
                                                                ,cc.subid
                                                        FROM
                                                                clipcards cc 
                                                        JOIN
                                                                persons p
                                                                ON p.center = cc.owner_center
                                                                AND p.id = cc.owner_id
                                                        LEFT JOIN
                                                                person_ext_attrs peaMobile
                                                                ON peaMobile.personcenter = p.center
                                                                AND peaMobile.personid = p.id
                                                                AND peaMobile.name = '_eClub_PhoneSMS'
                                                        LEFT JOIN
                                                                person_ext_attrs peaEmail
                                                                ON peaEmail.personcenter = p.center
                                                                AND peaEmail.personid = p.id
                                                                AND peaEmail.name = '_eClub_Email' 
                                                        JOIN 
                                                                products prod 
                                                                ON prod.center = cc.center
                                                                AND prod.id = cc.ID 
                                                        JOIN
                                                                product_group_flags pgf
                                                                ON pgf.center = prod.center
                                                                AND pgf.id = prod.id      
                                                        JOIN                                                 
                                                                invoices inv
                                                                ON inv.center = cc.invoiceline_center
                                                                AND inv.id = cc.invoiceline_id								
                                                        JOIN
                                                                invoice_lines_mt invl
                                                                ON cc.invoiceline_center = invl.center
                                                                AND cc.invoiceline_id = invl.id
                                                                AND cc.invoiceline_subid = invl.subid                                     
                                                        JOIN
                                                                employees emp
                                                                ON emp.center = inv.employee_center
                                                                AND emp.id = inv.employee_id
                                                        JOIN
                                                                persons pemp
                                                                ON pemp.center = emp.personcenter
                                                                AND pemp.id = emp.personid
                                                        LEFT JOIN                                                 
                                                                invoice_sales_employee ins
                                                                ON ins.invoice_center = inv.center
                                                                AND ins.invoice_id = inv.id  
                                                        LEFT JOIN
                                                                employees emps
                                                                ON emps.center = ins.sales_employee_center
                                                                AND emps.id = ins.sales_employee_id
                                                        LEFT JOIN
                                                                persons pemps
                                                                ON pemps.center = emps.personcenter
                                                                AND pemps.id = emps.personid   
                                                        JOIN 
                                                                params 
                                                                ON params.CENTER_ID = p.center
                                                        JOIN
                                                                centers c
                                                                ON c.id = p.center                                           
                                                        WHERE 
                                                                cc.cancelled IS FALSE
                                                                AND
                                                                cc.blocked IS FALSE
                                                                AND
                                                                inv.trans_time BETWEEN params.FromDate AND params.ToDate 
                                                                AND 
                                                                p.center IN (:Scope)
                                                                AND
                                                                (inv.paysessionid IS NOT NULL OR inv.employee_center||'emp'||inv.employee_id IN ('100emp2202', '100emp409')) 
                                )t1
                                        GROUP BY
                                                t1."Member Full Name"
                                                ,t1.center
                                                ,t1.id
                                                ,t1."Mobile Number"
                                                ,t1."Email Address"
                                                ,t1."Service Purchased"
                                                ,t1."Purchase Date"
                                                ,t1."Staff Member"
                                                ,t1."Sold on behalf of"
                                                ,t1.product_group                                        
                                                ,t1.name
                                                ,t1.status
                                                ,t1.BindingPeriod
                                                ,t1.type
                                                ,t1.external_id                                                                                                        
                        )t1
                GROUP BY
                        t1."Member Full Name"
                        ,t1.center
                        ,t1.id
                        ,t1."Mobile Number"
                        ,t1."Email Address"
                        ,t1."Service Purchased"
                        ,t1."Purchase Date"
                        ,t1."Staff Member"
                        ,t1."Sold on behalf of"
                        ,t1.productgroup
                        ,t1.name
                        ,t1.GrossValue
                        ,t1.status
                        ,t1.BindingPeriod
                        ,t1.type
                        ,t1.external_id
                )t1                                
        LEFT JOIN
                installment_plans ip
                ON ip.person_center = t1.center
                AND ip.person_id = t1.id
                AND ip.end_date > current_date
        LEFT JOIN
                lastattend
                ON lastattend.center = t1.center
                AND lastattend.id = t1.id
                AND lastattend.ProductGroup = t1.productgroup 
        WHERE
                t1."Service Purchased" NOT LIKE '%Comp%'                                                           
        )t