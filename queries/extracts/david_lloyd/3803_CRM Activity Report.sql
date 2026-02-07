-- This is the version from 2026-02-05
--  
WITH
    params AS MATERIALIZED
    ( SELECT
        --            CURRENT_DATE-interval '1 day' AS from_date ,
        --            CURRENT_DATE                  AS to_date
        c.id                                        AS center
        , datetolongc($$from_date$$:: DATE::VARCHAR,c.id)                  AS from_date_long
        , datetolongc($$to_date$$:: DATE::VARCHAR,c.id)+1000*60*60*24 -1 AS to_date_long
        , datetolongc(add_months($$from_date$$:: DATE,-3)::VARCHAR,c.id)   AS from_1_months_date_long
        , $$from_date$$:: DATE                                             AS from_date
        , $$to_date$$:: DATE                                             AS to_date
    FROM
        centers c
    WHERE
        c.id IN ($$scope$$)
    )
    , crm_activity AS
    (SELECT
        tl.employee_center      AS emp_center
        , tl.employee_id        AS emp_id
        , tld_user_choice.VALUE AS activity_Type
        ,tl.entry_time
    FROM
        task_log tl
    JOIN
        tasks t
    ON
        t.id = tl.task_id
    JOIN
        TASK_TYPES tt
    ON
        tt.id = t.type_id
    JOIN
        WORKFLOWS wf
    ON
        wf.ID = tt.WORKFLOW_ID
    JOIN
        task_actions ta
    ON
        ta.id = tl.task_action_id
    JOIN
        persons p
    ON
        p.center = t.person_center
    AND p.id = t.person_id
    JOIN
        TASK_LOG_DETAILS tld_user_choice
    ON
        tld_user_choice.TASK_LOG_ID = tl.id
    AND tld_user_choice.NAME = 'RequirementType.USER_CHOICE'
    WHERE
        wf.name = 'Lead Management'
    AND ta.name = 'Contact'
    )
    , tours AS
    ( SELECT
        longtodatec(bk.starttime,bk.center)         AS tour_start_datetime
        , longtodatec(par.creation_time,par.center) AS tour_creation_datetime
        ,su.person_center
        ,su.person_id
        ,a.name AS activity_type
    FROM
        params
    JOIN
        participations par
    ON
        par.center = params.center
    JOIN
        bookings bk
    ON
        bk.center = par.booking_center
    AND bk.id = par.booking_id
    JOIN
        activity a
    ON
        a.id = bk.activity
    JOIN
        persons p
    ON
        p.center = par.participant_center
    AND p.id = par.participant_id
    JOIN
        staff_usage su
    ON
        su.booking_center = bk.center
    AND su.booking_id = bk.id
    AND su.cancellation_time IS NULL
    WHERE
        bk.starttime BETWEEN params.from_date_long AND params.to_date_long
    AND par.state = 'PARTICIPATION'
    )
    , trial_products AS
    (SELECT
        DISTINCT pr.center
        ,pr.id
    FROM
        products pr
    JOIN
        product_and_product_group_link ppgl
    ON
        pr.center = ppgl.product_center
    AND pr.id = ppgl.product_id
    AND ppgl.product_group_id IN (341,358)
    )
    , open_task AS
    (SELECT
        t.id
        , t.asignee_center AS emp_center
        ,t.asignee_id      AS emp_id
        ,tc.name ||' '||
        CASE
            WHEN p.STATUS = 0
            THEN 'Lead'
            WHEN p.STATUS = 6
            THEN 'Prospect'
            WHEN p.STATUS = 1
            AND st.center IS NOT NULL
            THEN 'Trial'
        END      AS activity_type
        ,tc.name AS task_category
        ,t.status
        ,st.center IS NOT NULL AS is_trial
    FROM
        params
    JOIN
        tasks t
    ON
        t.person_center = params.center
    LEFT JOIN
        task_categories tc
    ON
        tc.id = t.task_category_id
    JOIN
        persons p
    ON
        p.center = t.person_center
    AND p.id= t.person_id
    LEFT JOIN
        subscriptions s
    ON
        s.owner_center = p.center
    AND s.owner_id = p.id
    AND s.state IN (2,4)
    LEFT JOIN
        trial_products st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    WHERE
        t.status = 'OPEN'
    )
    , new_leads AS
    (SELECT
        t.id
        , t.asignee_center AS emp_center
        ,t.asignee_id      AS emp_id
        ,'New '||
        CASE
            WHEN p.STATUS = 0
            THEN 'Lead'
            WHEN p.STATUS IN( 6,1)
            THEN 'Prospect'
        END AS activity_type
        ,t.status
    FROM
        params
    JOIN
        tasks t
    ON
        t.person_center = params.center
    JOIN
        persons p
    ON
        p.center = t.person_center
    AND p.id= t.person_id
    WHERE
        t.creation_time >= from_1_months_date_long
    )
    , sales AS
    ( SELECT
        COALESCE(ise.sales_employee_center,emp.center) AS emp_center
        , COALESCE(ise.sales_employee_id,emp.id)       AS emp_id
        , CASE
            WHEN EXISTS
                (SELECT
                    1
                FROM
                    tasks t
                WHERE
                    t.person_center = ss.owner_center
                AND t.person_id = ss.owner_id
                AND longtodatec(t.creation_time ,t.person_center) BETWEEN date_trunc('month',
                    ss.sales_date)-interval '1 month' AND date_trunc('month', ss.sales_date))
            THEN 'Last Month Lead Sale'
            ELSE 'Sale'
        END AS activity_type
    FROM
        params
    JOIN
        subscription_sales ss
    ON
        params.center = ss.subscription_center
    JOIN
        persons p
    ON
        p.center = ss.owner_center
    AND p.id = ss.owner_id
    JOIN
        subscriptions s
    ON
        s.center = ss.subscription_center
    AND s.id = ss.subscription_id
    LEFT JOIN
        invoice_sales_employee ise
    ON
        ise.invoice_center = s.invoiceline_center
    AND ise.invoice_id = s.invoiceline_id
    AND ise.stop_time IS NULL
    LEFT JOIN
        EMPLOYEES assigned_sales_emp
    ON
        assigned_sales_emp.center = ise.sales_employee_center
    AND assigned_sales_emp.id = ise.sales_employee_id
    LEFT JOIN
        PERSONS assigned_sales_staff
    ON
        assigned_sales_staff.center = assigned_sales_emp.personcenter
    AND assigned_sales_staff.ID = assigned_sales_emp.personid
    JOIN
        employees emp
    ON
        emp.center = ss.employee_center
    AND emp.id = ss.employee_id
    JOIN
        subscriptiontypes st
    ON
        st.center = s.subscriptiontype_center
    AND st.id = s.subscriptiontype_id
    AND NOT
        (
            st.IS_ADDON_SUBSCRIPTION)
    WHERE
        ss.sales_date BETWEEN params.from_Date AND params.to_date
    )
SELECT
    c.name                                    AS "Club"
    , a.name                                  AS "Region"
    , p.fullname                              AS "Employee Name"
    ,emp_center||'emp'||emp_id                AS "Employee ID"
    , SUM((activity_type = 'Call')::               INTEGER) AS "Call Volumes"
    , SUM((activity_type = 'Email')::              INTEGER) AS "Email Volumes"
    , SUM((activity_type = 'Club Tour')::          INTEGER) AS "Club Tour Appointment"
    , SUM((activity_type = 'Club Tour Trial')::    INTEGER) AS "Club Tour Trial Appointment"
    , SUM((activity_type = 'Member Meeting')::     INTEGER) AS "Member Meeting Appointment"
    , SUM((activity_type = 'Sign Up Appointment')::INTEGER) AS "Sign Up Appointment"
    , SUM((activity_type = 'Walk In Appointment')::INTEGER) AS "Walkin Appointment"
    , SUM((activity_type = 'Welcome Meeting')::    INTEGER) AS "Welcome Meeting Appointment"
    , SUM((activity_type IN('Club Tour'
                            ,'Club Tour Trial'
                            , 'Member Meeting'
                            , 'Sign Up Appointment'
                            , 'Walk In Appointment'
                            , 'Welcome Meeting')):: INTEGER) AS "Total Appointments"
    , SUM((activity_type = 'Cold Lead')::           INTEGER) AS "Cold Lead Volumes"
    , SUM((activity_type = 'Warm Lead')::           INTEGER) AS "Warm Lead Volumes"
    , SUM((activity_type = 'Hot Lead')::            INTEGER) AS "Hot Lead Volumes "
    , SUM((activity_type = 'Hot Prospect')::        INTEGER) AS "Hot Prospect Volumes"
    , SUM((activity_type LIKE '% Trial')::          INTEGER) AS "Assigned Trial Volumes"
    , SUM((activity_type IN('Sale'
                            ,'Last Month Lead Sale')):: INTEGER) AS "Sales"
    , SUM((activity_type = 'Last Month Lead Sale')::    INTEGER) AS
    "Sales from Previous month's leads"
    ,SUM((activity_type IN('New Lead'
                           , 'New Prospect')):: INTEGER) AS "New Leads"
    ,SUM((activity_type IN('New Prospect'))::   INTEGER) AS "New Prospects"
    ,ROUND(SUM((activity_type IN('Sale'
                                 , 'Last Month Lead Sale' )):: INTEGER::NUMERIC)/GREATEST(SUM ( 
    (activity_type IN('New Lead'
                      , 'New Prospect')):: INTEGER),1),2) AS "Lead / Sale Ratio"
    , ROUND(SUM((activity_type IN('Sale'
                                  , 'Last Month Lead Sale' )):: INTEGER::NUMERIC)/GREATEST(SUM ( 
    (activity_type = 'New Prospect'):: INTEGER) ,1),2) AS "Prospect / Sale Ratio"
    , ROUND(SUM((activity_type IN('Sale'
                                  , 'Last Month Lead Sale' )):: INTEGER::NUMERIC)/GREATEST(SUM 
    ( (activity_type IN('Club Tour'
                        ,'Club Tour Trial'
                        , 'Member Meeting'
                        , 'Sign Up Appointment'
                        , 'Walk In Appointment'
                        , 'Welcome Meeting')):: INTEGER),1),2) AS "Appointment / Sale Ratio"
    ,ROUND(SUM((activity_type IN('Club Tour'
                                 ,'Club Tour Trial'
                                 , 'Member Meeting'
                                 , 'Sign Up Appointment'
                                 , 'Walk In Appointment'
                                 , 'Welcome Meeting')) :: INTEGER::NUMERIC) /GREATEST(SUM(
    (activity_type = 'Call' ):: INTEGER),1),2) AS "Call / Appointment Ratio"
FROM
    ( SELECT
        emp.center AS emp_center
        ,emp.id    AS emp_id
        ,activity_type
        ,'tours' AS cte
    FROM
        employees emp
    JOIN
        tours
    ON
        emp.personcenter = tours.person_center
    AND emp.personid = tours.person_id
    
    UNION ALL
    
    SELECT
        emp_center
        , emp_id
        , activity_type
        ,'crm_activity' AS cte
    FROM
        crm_activity
    
    UNION ALL
    
    SELECT
        emp_center
        , emp_id
        , activity_type
        ,'sales' AS cte
    FROM
        sales
    
    UNION ALL
    
    SELECT
        emp_center
        , emp_id
        , activity_type
        ,'open_task' AS cte
    FROM
        open_task
    
    UNION ALL
    
    SELECT
        emp_center
        , emp_id
        , activity_type
        ,'new_leads' AS cte
    FROM
        new_leads ) t
JOIN
    employees emp
ON
    emp.center = t.emp_center
AND emp.id = t.emp_id
JOIN
    persons p
ON
    emp.personcenter = p.center
AND emp.personid = p.id
JOIN
    centers c
ON
    c.id = emp.center
JOIN
    area_centers ac
ON
    c.id = ac.center
JOIN
    areas a
ON
    a.id = ac.area
AND a.root_area = 11
where emp.center in ($$scope$$)
GROUP BY
    emp_center
    ,emp_id
    ,c.name
    ,p.fullname
    ,a.name