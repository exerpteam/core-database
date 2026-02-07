WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST('2022-01-01' AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST('2026-12-31' AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT   
        ts.name AS "Task Step"
        ,t.title AS "Task Title"
        ,t1.Category AS "Task Category"
        ,c.shortname AS "Center"        
        ,p.center||'p'||p.id AS "Person ID"
        ,p.fullname AS "Person Full Name"
        ,p.firstname AS "Person First Name"
        ,p.lastname AS "Person Last Name"
        ,CASE
                p.status
                WHEN 0 THEN 'Lead'
                WHEN 1 THEN 'Active'
                WHEN 2 THEN 'Inactive'
                WHEN 3 THEN 'TemporaryInactive'
                WHEN 4 THEN 'Transferred'
                WHEN 5 THEN 'Duplicate'
                WHEN 6 THEN 'Prospect'
                WHEN 7 THEN 'Deleted'
                WHEN 8 THEN 'Anonymized'
                WHEN 9 THEN 'Contact'
                ELSE 'Undefined'
        END AS "Member Status"
        ,t.status AS "Task Status"
        ,assignee.fullname AS "Task Assigned to"
        ,t.follow_up AS "Task Follow-up"
        ,TO_CHAR(longtodateC(t.creation_time,t.asignee_center),'YYYY-MM-DD') AS "Task created date"
        ,TO_CHAR(longtodateC(t.last_update_time,t.asignee_center),'YYYY-MM-DD') AS "Task Last updated"   
        ,ar.balance AS "Account Balance" 
        ,(CASE  
                WHEN pag.payment_cycle_config_id = 401 THEN 'Small billing'
                WHEN pag.payment_cycle_config_id = 1 THEN 'Big billing'
                ELSE 'FF_Invoice'
        END) AS "Payment Cycle"       
        ,GuardianName.txtvalue AS "Guardian Name"
        ,GuardianRelation.txtvalue AS "Guardian Relation"
        ,p.external_id AS "External ID"
		,eac.balance AS "Member Debt Collector Balance"
		,p.external_id AS "External ID"
 ,CASE 
            WHEN e_collect_pea.txtvalue ILIKE 'yes%' THEN 'Yes' 
            ELSE 'No' 
         END AS "eCollect"
FROM 
        tasks t
JOIN
        (SELECT 
                MAX(task.id) AS MAXID
                ,task.person_center AS PersonCenter
                ,task.person_id AS PersonID
                ,tc.name AS Category
        FROM 
                tasks task
        JOIN 
                params 
                        ON params.CENTER_ID = task.person_center
        JOIN
                task_types tt
                        ON tt.id = task.type_id
                        AND tt.external_id = 'DM_NEW'                                        
        LEFT JOIN
                task_categories tc
                        ON task.task_category_id = tc.id 
        WHERE 
                task.status NOT IN ('CLOSED','DELETED')
                AND
                task.last_update_time BETWEEN params.FromDate AND params.ToDate
                AND
                task.person_center in (:Scope)
        GROUP BY
                task.person_center
                ,task.person_id
                ,tc.name
        )t1
                ON t1.MAXID = t.id
                AND t1.PersonCenter = t.person_center
                AND t1.PersonID = t.person_id                        
LEFT JOIN 
        task_steps ts 
                ON ts.id = t.step_id
JOIN
        persons p
                ON p.center = t.person_center
                AND p.id = t.person_id  
LEFT JOIN
        persons assignee
                ON assignee.center = t.asignee_center
                AND assignee.id = t.asignee_id  
JOIN
        centers c
                ON c.id = t.person_center   
LEFT JOIN
        person_ext_attrs pea
                ON pea.personcenter = p.center
                AND pea.personid = p.id
                AND pea.name = '_eClub_Email' 
LEFT JOIN
        zipcodes zc
                ON zc.zipcode = p.zipcode 
		AND zc.city = p.city
LEFT JOIN 
        account_receivables ar 
                ON p.center = ar.customercenter 
                AND p.id = ar.customerid 
                AND ar.ar_type = 4   
LEFT JOIN 
        payment_accounts pac 
                ON pac.center = ar.center 
                AND pac.id = ar.id
LEFT JOIN 
        payment_agreements pag 
                ON pac.active_agr_center = pag.center 
                AND pac.active_agr_id = pag.id 
                AND pac.active_agr_subid = pag.subid
LEFT JOIN
        person_ext_attrs GuardianEmail
                ON GuardianEmail.personcenter = p.center
                AND GuardianEmail.personid = p.id 
                AND GuardianEmail.name = 'GuardianEmail'
LEFT JOIN
        person_ext_attrs GuardianRelation
                ON GuardianRelation.personcenter = p.center
                AND GuardianRelation.personid = p.id 
                AND GuardianRelation.name = 'GuardianRelation'                
LEFT JOIN
        person_ext_attrs GuardianName
                ON GuardianName.personcenter = p.center
                AND GuardianName.personid = p.id 
                AND GuardianName.name = 'GuardianName'                 
LEFT JOIN
        person_ext_attrs GuardianAddress
                ON GuardianAddress.personcenter = p.center
                AND GuardianAddress.personid = p.id 
                AND GuardianAddress.name = 'GuardianAddress'    
LEFT JOIN
        person_ext_attrs GuardianContactNumber
                ON GuardianContactNumber.personcenter = p.center
                AND GuardianContactNumber.personid = p.id 
                AND GuardianContactNumber.name = 'GuardianContactNumber' 
LEFT JOIN 
        account_receivables eac
                ON p.center = eac.customercenter 
                AND p.id = eac.customerid 
                AND eac.ar_type = 5    
LEFT JOIN
        person_ext_attrs e_collect_pea
                ON e_collect_pea.personcenter = p.center
                AND e_collect_pea.personid   = p.id
                AND e_collect_pea.name       = 'eCollect';              
