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
  )               
SELECT 
        c.SHORTNAME AS "Center Name"
        ,p.CENTER || 'p' || p.ID AS "Person ID"
        ,p.FULLNAME AS "Member Name"
        ,p.FIRSTNAME AS "First Name"
        ,p.LASTNAME AS "Last Name"
        ,peeaMobile.txtvalue AS "Mobile"
        ,peeaEmail.txtvalue AS "Email"
        ,p.FIRST_ACTIVE_START_DATE AS "Join Date"
        ,longtodatec(s.creation_time,p.center) AS "Subscription Creation Date"
        ,s.START_DATE AS "Subscription Start Date"
        ,pe.FULLNAME AS "Sales Person"
        ,pes.firstname || ' ' || pes.lastname AS "Sold on behalf of"
        ,CASE 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 0 THEN 'None' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 1 THEN 'Joiner' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 2 THEN 'Reactivated' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 3 THEN 'Rejoiner' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 4 THEN 'Transfer' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 5 THEN 'Member' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 6 THEN 'SecondaryMember' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 7 THEN 'Joiner' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 8 THEN 'ExMember' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 9 THEN 'Regret' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 10 THEN 'Cancel' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 11 THEN 'Undelete' 
                WHEN rea.center IS NULL AND scl.SUB_STATE = 12 THEN 'LegacyMember' 
                ELSE 'Undefined' 
        END AS "Change Type"
        ,longtodatec(s.creation_time,p.center) AS "Change Date"
        ,prod.NAME AS "Subscription Name"
        ,bi_decode_field('PERSONS', 'PERSONTYPE', p.persontype) AS "Person Type"
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
                WHEN s.state = 2 THEN 'Active'
                WHEN s.state = 3 THEN 'Ended'
                WHEN s.state = 4 THEN 'Frozen'
                WHEN s.state = 7 THEN 'Window'
                WHEN s.state = 8 THEN 'Created'
                ELSE 'Unknown'
        END AS "Subscription Status"
        ,ar.balance AS "Account Balance"
        ,CASE
                WHEN ss.price_period IS NOT NULL THEN ss.price_period
                ELSE sp.price
        END AS "DD Amount"
FROM
        fernwood.subscriptions s        
JOIN
        fernwood.subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.ID = s.subscriptiontype_id
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
        fernwood.account_receivables ar
        ON p.center = ar.customercenter 
        AND p.id = ar.customerid 
        AND ar.ar_type = 4
JOIN    
        fernwood.employees emp
        ON emp.center = s.creator_center
        AND emp.id = s.creator_id
JOIN
        fernwood.persons pe
        ON pe.CENTER = emp.personcenter
        AND pe.ID = emp.personid            
LEFT JOIN
        fernwood.subscription_sales ss
        ON s.center = ss.subscription_center
        AND s.id = ss.subscription_id
LEFT JOIN     
        fernwood.employees emps
        ON emps.center = ss.employee_center
        AND emps.id = ss.employee_id
LEFT JOIN
        fernwood.persons pes
        ON pes.center = emps.personcenter
        AND pes.id = emps.personid
LEFT JOIN 
        fernwood.person_ext_attrs peeaMobile
        ON peeaMobile.personcenter = p.center
        AND peeaMobile.personid = p.id
        AND peeaMobile.name = '_eClub_PhoneSMS' 
LEFT JOIN 
        fernwood.person_ext_attrs peeaEmail
        ON peeaEmail.personcenter = p.center
        AND peeaEmail.personid = p.id
        AND peeaEmail.name = '_eClub_Email'                                      
LEFT JOIN
        fernwood.state_change_log scl
        ON scl.center = p.center
        AND scl.id = p.id        
        AND scl.entry_type = 5
        --AND TO_CHAR(longtodatec(s.creation_time,p.center),'DD-MM-YYYY') = TO_CHAR(longtodatec(scl.entry_start_time,p.center),'DD-MM-YYYY')        
        AND scl.entry_end_time IS NULL
LEFT JOIN
        fernwood.subscriptions rea
        ON rea.reassigned_center = s.center     
        AND rea.reassigned_id = s.id
LEFT JOIN
        fernwood.subscription_price sp
        ON sp.subscription_center = s.center
        AND sp.subscription_id = s.id
        AND s.START_DATE > sp.from_date
        AND (s.START_DATE < sp.to_date OR sp.to_date IS NULL)        
JOIN 
        params 
        ON params.CENTER_ID = s.center                   
WHERE 
        s.CREATION_TIME BETWEEN params.FromDate AND params.ToDate 
        AND 
        s.state not in (3)
        AND
        rea.center IS NULL
        AND
        s.center in (:Scope)
