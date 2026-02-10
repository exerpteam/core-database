-- The extract is extracted from Exerp on 2026-02-08
--  
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
        p.center ||'p'|| p.id AS "Person ID"
        ,p.external_id AS "External ID"
        ,p.firstname AS "Lead First Name"
        ,p.lastname AS "Lead Last Name"
        ,CASE
                WHEN p.status=0 THEN 'Lead'
                WHEN p.status=1 THEN 'Active'
                WHEN p.status=2 THEN 'Inactive'
                WHEN p.status=3 THEN 'Temporary Inactive'
                WHEN p.status=4 THEN 'Transferred'
                WHEN p.status=5 THEN 'Duplicate'
                WHEN p.status=6 THEN 'Prospect'
                WHEN p.status=7 THEN 'Deleted'
                WHEN p.status=8 THEN 'Anonymized'
                WHEN p.status=9 THEN 'Contact'
	END AS "Person Status"
        ,c.name AS "Home Club"
        ,peaMobile.txtvalue AS "Contact Number"
        ,peaEmail.txtvalue AS "Email"
        ,pea.txtvalue AS "Person Creation Date"
        ,peaSource.txtvalue AS "Campaign Source"
        ,CAST(longtodateC(t.creation_time,t.center) AS DATE) AS "Task creation date"
        ,t.status AS "Task Status"
        ,ts.name AS "Task Step"
        ,assignee.fullname AS "Assigned to"
        ,CAST(longtodateC(t.last_update_time,t.asignee_center) AS DATE) AS "Last Updated"
        ,t.follow_up AS "Follow-up Date"
        ,tcomment.value AS "Last Comment"
        ,empp.fullname || '-' ||  longtodateC(tlog.entry_time,tlog.employee_center) AS LastComment
FROM
        tasks t                
LEFT JOIN
        task_steps ts
                ON ts.id = t.step_id            
JOIN
        persons p
                ON p.center = t.person_center
                AND p.id = t.person_id
LEFT JOIN
        (SELECT 
                max(tld.task_log_id) AS TaskID
                ,tk.person_center
                ,tk.person_id
        FROM
                task_log tl
        JOIN
                task_log_details tld
                ON tld.task_log_id = tl.id
                AND tld.name = '_eClub_COMMENT'
        JOIN
                tasks tk
                ON tk.id = tl.task_id                
        GROUP BY
                tk.person_center
                ,tk.person_id                                                    
        )tc
                ON tc.person_center = p.center
                AND tc.person_id = p.id 
LEFT JOIN
        task_log_details tcomment
                ON tcomment.task_log_id = tc.TaskID
                AND tcomment.name = '_eClub_COMMENT'
LEFT JOIN
        task_log tlog
                ON tcomment.task_log_id = tlog.id                
LEFT JOIN
        persons empp
                ON empp.center = tlog.employee_center
                AND empp.id = tlog.employee_id                                                                                   
LEFT JOIN
        persons assignee
                ON assignee.center = t.asignee_center
                AND assignee.id = t.asignee_id  
JOIN
        centers c
                ON c.id = t.person_center  
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
LEFT JOIN
        person_ext_attrs peaSource
                ON peaSource.personcenter = p.center
                AND peaSource.personid = p.id
                AND peaSource.name = 'CampaignSource'  
LEFT JOIN
        person_ext_attrs pea
                ON pea.personcenter = p.center
                AND pea.personid = p.id
                AND pea.name = 'CREATION_DATE'                                                                
JOIN
        params 
                ON params.CENTER_ID = t.person_center                     
WHERE
        t.type_id = 800
		AND 
		t.permanent_note != 'Leads Transferred From Old CRM'
        AND
        p.center in (:Scope)
        AND
        t.creation_time BETWEEN params.FromDate AND params.ToDate