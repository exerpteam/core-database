WITH
  Open_Debt_Step AS --centers to be added and removed here
  (
        SELECT 
                MAX(task.id) AS MAXID
                ,task.person_center AS PersonCenter
                ,task.person_id AS PersonID
        FROM 
                fernwood.tasks task
        JOIN
                fernwood.task_types tt
                        ON tt.id = task.type_id
                        AND tt.external_id = 'DM_NEW'                                        
        WHERE 
                task.status NOT IN ('CLOSED','DELETED')
                AND
                task.follow_up = CURRENT_DATE
                AND
                task.person_center in (:Scope) 
        GROUP BY
                task.person_center
                ,task.person_id
  ),
  Club_TALKBOXID AS --Steps to be added and removed here
  (
        SELECT 
                c.id
                ,c.shortname
                ,cea.txt_value AS Talkbox_ID
        FROM
                fernwood.centers c
        JOIN
                fernwood.center_ext_attrs cea
                ON cea.center_id = c.id
                AND cea.name = 'TALKBOXID'                
  ),
  Talkbox_Task_steps AS                                                                      
  (
        SELECT 
                ts.id
                ,ts.name
                ,CASE 
                        WHEN ts.name IN ('1 - R1 CC Send SMS'
                                        ,'1 - R1 CC Send SMS EC'
                                        ,'1 - R1 CC Send SMS PP'
                                        ,'1 - R1 BA Send SMS'
                                        ,'1 - R1 BA Send SMS EC'
                                        ,'1 - R1 BA Send SMS PP') THEN '1'
                        WHEN ts.name IN ('2 - R1 CC Send Email'
                                        ,'2 - R1 CC Send Email EC'
                                        ,'2 - R1 CC Send Email PP'
                                        ,'2 - R1 BA Send Email'
                                        ,'2 - R1 BA Send Email EC'
                                        ,'2 - R1 BA Send Email PP') THEN '2'
                        WHEN ts.name IN ('3 - R1 CC Reminder SMS'
                                        ,'3 - R1 CC Reminder SMS EC'
                                        ,'3 - R1 CC Reminder SMS PP'
                                        ,'3 - R1 BA Reminder SMS'
                                        ,'3 - R1 BA Reminder SMS EC'
                                        ,'3 - R1 BA Reminder SMS PP') THEN '3'
                        WHEN ts.name IN ('4 - R1 CC Follow up SMS'
                                        ,'4 - R1 CC Follow up SMS EC'
                                        ,'4 - R1 CC Follow up SMS PP'
                                        ,'4 - R1 BA Follow up SMS'
                                        ,'4 - R1 BA Follow up SMS EC'
                                        ,'4 - R1 BA Follow up SMS PP') THEN '4'
                        WHEN ts.name IN ('5 - R1 CC Follow up Email'
                                        ,'5 - R1 CC Follow up Email EC'
                                        ,'5 - R1 CC Follow up Email PP'
                                        ,'5 - R1 BA Follow up Email'
                                        ,'5 - R1 BA Follow up Email EC'
                                        ,'5 - R1 BA Follow up Email PP') THEN '5'
                        WHEN ts.name IN ('7 - R2 CC Send SMS'
                                        ,'7 - R2 CC Send SMS EC'
                                        ,'7 - R2 CC Send SMS PP'
                                        ,'7 - R2 BA Send SMS'
                                        ,'7 - R2 BA Send SMS EC'
                                        ,'7 - R2 BA Send SMS PP') THEN '7'
                        WHEN ts.name IN ('8 - R2 CC Send Email'	
                                        ,'8 - R2 CC Send Email EC'	
                                        ,'8 - R2 CC Send Email PP'	
                                        ,'8 - R2 BA Send Email'	
                                        ,'8 - R2 BA Send Email EC'	
                                        ,'8 - R2 BA Send Email PP') THEN '8'
                        WHEN ts.name IN ('10 - R2 CC Reminder SMS'	
                                        ,'10 - R2 CC Reminder SMS EC'	
                                        ,'10 - R2 CC Reminder SMS PP'	
                                        ,'10 - R2 BA Reminder SMS'	
                                        ,'10 - R2 BA Reminder SMS EC'	
                                        ,'10 - R2 BA Reminder SMS PP'
                                        ,'10 - R2 CC Reminder SMS + Call'	
                                        ,'10 - R2 CC Reminder SMS + Call EC'	
                                        ,'10 - R2 CC Reminder SMS + Call PP'	
                                        ,'10 - R2 BA Reminder SMS + Call'	
                                        ,'10 - R2 BA Reminder SMS + Call EC'	
                                        ,'10 - R2 BA Reminder SMS + Call PP') THEN '10'
                        WHEN ts.name IN ('11 - R2 CC Follow up SMS'	
                                        ,'11 - R2 CC Follow up SMS EC'	
                                        ,'11 - R2 CC Follow up SMS PP'	
                                        ,'11 - R2 BA Follow up SMS'	
                                        ,'11 - R2 BA Follow up SMS EC'	
                                        ,'11 - R2 BA Follow up SMS PP') THEN '11'
                        WHEN ts.name IN ('12 - R2 CC Follow up Email'	
                                        ,'12 - R2 CC Follow up Email EC'	
                                        ,'12 - R2 CC Follow up Email PP'	
                                        ,'12 - R2 BA Follow up Email'	
                                        ,'12 - R2 BA Follow up Email EC'	
                                        ,'12 - R2 BA Follow up Email PP') THEN '12'
                        WHEN ts.name IN ('14 - R3 CC Send SMS'	
                                        ,'14 - R3 CC Send SMS EC'	
                                        ,'14 - R3 CC Send SMS PP'	
                                        ,'14 - R3 BA Send SMS'	
                                        ,'14 - R3 BA Send SMS EC'	
                                        ,'14 - R3 BA Send SMS PP') THEN '14'
                        WHEN ts.name IN ('15 - R3 CC Send Email'	
                                        ,'15 - R3 CC Send Email EC'	
                                        ,'15 - R3 CC Send Email PP'	
                                        ,'15 - R3 BA Send Email'	
                                        ,'15 - R3 BA Send Email EC'	
                                        ,'15 - R3 BA Send Email PP') THEN '15'
                        WHEN ts.name IN ('17 - R3 CC Reminder SMS'	
                                        ,'17 - R3 CC Reminder SMS EC'	
                                        ,'17 - R3 CC Reminder SMS PP'	
                                        ,'17 - R3 BA Reminder SMS'	
                                        ,'17 - R3 BA Reminder SMS EC'	
                                        ,'17 - R3 BA Reminder SMS PP'
                                        ,'17 - R3 CC Reminder SMS + Call'	
                                        ,'17 - R3 CC Reminder SMS + Call EC'	
                                        ,'17 - R3 CC Reminder SMS + Call PP'	
                                        ,'17 - R3 BA Reminder SMS + Call'	
                                        ,'17 - R3 BA Reminder SMS + Call EC'	
                                        ,'17 - R3 BA Reminder SMS + Call PP') THEN '17'
                        WHEN ts.name IN ('18 - R3 CC Follow up SMS'	
                                        ,'18 - R3 CC Follow up SMS EC'	
                                        ,'18 - R3 CC Follow up SMS PP'	
                                        ,'18 - R3 BA Follow up SMS'	
                                        ,'18 - R3 BA Follow up SMS EC'	
                                        ,'18 - R3 BA Follow up SMS PP') THEN '18'
                        WHEN ts.name IN ('19 - R3 CC Follow up Email'	
                                        ,'19 - R3 CC Follow up Email EC'	
                                        ,'19 - R3 CC Follow up Email PP'	
                                        ,'19 - R3 BA Follow up Email'	
                                        ,'19 - R3 BA Follow up Email EC'	
                                        ,'19 - R3 BA Follow up Email PP') THEN '19'
                        WHEN ts.name IN ('21 - CC Final SMS'	
                                        ,'21 - CC Final SMS EC'	
                                        ,'21 - CC Final SMS PP'	
                                        ,'21 - BA Final SMS'	
                                        ,'21 - BA Final SMS EC'	
                                        ,'21 - BA Final SMS PP') THEN '21'
                        WHEN ts.name IN ('23 - CC Final Notice'	
                                        ,'23 - CC Final Notice EC'	
                                        ,'23 - CC Final Notice PP'	
                                        ,'23 - BA Final Notice'	
                                        ,'23 - BA Final Notice EC'	
                                        ,'23 - BA Final Notice PP') THEN '23'
                        ELSE 'Exclude'
                END AS Talkbox_Task                                                
                ,wf.external_id 
        FROM 
                fernwood.workflows wf
        JOIN
                fernwood.task_steps ts
                ON ts.workflow_id = wf.id        
        WHERE
                wf.external_id = 'DM_NEW'
  )                         
SELECT   
        COALESCE(p.external_id,tp.external_id) AS "External ID"
        ,p.fullname AS "Debtor Name"
        ,ar.balance AS "Debt Value"
        ,mobile.txtvalue AS "Mobile Number"
        ,ct.shortname AS "Location"  
        ,ct.Talkbox_ID AS "Talkbox ID"
        ,tts.Talkbox_Task AS "Debt Step"
        ,pea.txtvalue AS "Member Email"
FROM 
        fernwood.tasks t
JOIN
        Open_Debt_Step ods
                ON ods.MAXID = t.id
                AND ods.PersonCenter = t.person_center
                AND ods.PersonID = t.person_id                        
LEFT JOIN 
        Talkbox_Task_steps tts 
                ON tts.id = t.step_id
JOIN
        fernwood.persons p
                ON p.center = t.person_center
                AND p.id = t.person_id  
LEFT JOIN
        fernwood.persons assignee
                ON assignee.center = t.asignee_center
                AND assignee.id = t.asignee_id  
JOIN
        Club_TALKBOXID ct
                ON ct.id = t.person_center   
LEFT JOIN
        fernwood.person_ext_attrs pea
                ON pea.personcenter = p.center
                AND pea.personid = p.id
                AND pea.name = '_eClub_Email' 
LEFT JOIN
        fernwood.person_ext_attrs mobile
                ON mobile.personcenter = p.center
                AND mobile.personid = p.id
                AND mobile.name = '_eClub_PhoneSMS'                 
LEFT JOIN 
        fernwood.account_receivables ar 
                ON p.center = ar.customercenter 
                AND p.id = ar.customerid 
                AND ar.ar_type = 4  
LEFT JOIN
        fernwood.persons tp
                ON tp.center = p.transfers_current_prs_center
                AND tp.id = p.transfers_current_prs_id
                AND p.external_id IS NULL                    
WHERE
        tts.Talkbox_Task != 'Exclude'                                                
        AND
        p.center NOT IN (601,303,204,305,102,702,309,311,602,314,320,321,322,105,11,314,704,312)
