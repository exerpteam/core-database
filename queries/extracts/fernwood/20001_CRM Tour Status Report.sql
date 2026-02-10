-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-4467
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
  ),
  activities AS
        (
        SELECT
                CASE
                        WHEN ac.id = 14201 THEN 1--'Chatbot'
                        WHEN ac.id in (14003,20401,42621,42811,43013,42812,42806,43007) THEN 2--'tour'
                        WHEN ac.id = 15003 THEN 3--'Induction'
                        WHEN ac.id = 1203 THEN 4--'Save'
                        WHEN ac.id = 1202 THEN 5--'renewal'
                END as activity
                ,ac.id                        
        FROM
                activity ac 
        WHERE
                ac.id in (14201,14003,20401,42621,42811,43013,42812,42806,43007,15003,1203,1202)
        ),
  task AS
        (
        SELECT 
                t2.status
                ,t2.person_center
                ,t2.person_id
        FROM
                tasks t2
        JOIN
                (
                SELECT 
                        max(t.id) AS ID
                        ,t.person_center
                        ,t.person_id
                FROM 
                        tasks t
                WHERE 
                        t.center in (:scope)
                GROUP BY
                        t.person_center
                        ,t.person_id
                )t 
                ON t2.person_center = t.person_center 
                AND t2.person_id = t.person_id
                AND t2.id = t.ID 
        )
SELECT
        t."Staff Member Number"
        ,t."Appointment ID"
        ,t."Person ID"
        ,t."Appointment Name"
        ,t."Mobile"
        ,t."Email"
        ,t."Appointment Type"
        ,t."Appointment Date" 
        ,t."Appointment Time"
        ,t."Appointment Status"       
        ,t."Appointment outcome"  
        ,t."CRM Task Status"
FROM
        (                
        SELECT 
                 su.person_center || 'p' || su.person_id AS "Staff Member Number"
                ,b.center||'book'||b.id AS "Appointment ID"
                ,p.center||'p'||p.id AS "Person ID"
                ,p.fullname AS "Appointment Name"
                ,peeaMobile.txtvalue AS "Mobile"
                ,peeaEmail.txtvalue AS "Email"
                ,b.name AS "Appointment Type"
                ,TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD') AS "Appointment Date" 
                ,TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI') AS "Appointment Time"
                ,part.state AS "Appointment Status"       
                ,CASE
                        WHEN p.status = 0 THEN 'Lead'
                        WHEN p.status = 1 THEN 'Active' 
                        WHEN p.status = 2 THEN 'Inactive' 
                        WHEN p.status = 3 THEN 'Temporary Inactive'                             
                        WHEN p.status = 6 THEN 'Prospect'
                        WHEN p.status = 9 THEN 'Contact'
                        ELSE ''
                END AS "Appointment outcome"  
                ,t2.status AS "CRM Task Status"
                ,p.status
        FROM
                bookings b
        JOIN 
                participations part 
                on b.id = part.booking_id
                AND b.center = part.booking_center
        JOIN 
                persons p 
                on p.id = part.participant_id
                AND p.center = part.participant_center
        JOIN 
                person_ext_attrs peeaEmail
                ON peeaEmail.personcenter = p.center
                AND peeaEmail.personid = p.id
                AND peeaEmail.name = '_eClub_Email'
        JOIN 
                person_ext_attrs peeaMobile
                ON peeaMobile.personcenter = p.center
                AND peeaMobile.personid = p.id
                AND peeaMobile.name = '_eClub_PhoneSMS'
        JOIN    
                params 
                ON params.CENTER_ID = b.center
        JOIN 
                activity ac 
                ON b.activity= ac.id
        JOIN
                activities a
                ON a.id = ac.id           
        JOIN 
                activity_group ag
                ON ac.activity_group_id = ag.id
        JOIN 
                staff_usage su
                ON su.booking_center = b.center 
                AND su.booking_id = b.id
                AND su.state = 'ACTIVE'     
        LEFT JOIN
                task t2
                ON t2.person_center = p.center 
                AND t2.person_id = p.id  
        WHERE
                p.status != 5 
                AND
                a.activity in (:activityname)
                AND 
                b.center in (:scope)
                AND 
                b.starttime BETWEEN params.FromDate AND params.ToDate
                AND 
                b.state != 'CANCELLED' 
        UNION ALL
        SELECT 
                 su.person_center || 'p' || su.person_id AS "Staff Member Number"
                ,b.center||'book'||b.id AS "Appointment ID"
                ,newp.center||'p'||newp.id AS "Person ID"
                ,newp.fullname AS "Appointment Name"
                ,peeaMobile.txtvalue AS "Mobile"
                ,peeaEmail.txtvalue AS "Email"
                ,b.name AS "Appointment Type"
                ,TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD') AS "Appointment Date" 
                ,TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI') AS "Appointment Time"
                ,part.state AS "Appointment Status"       
                ,CASE
                        WHEN newp.status = 0 THEN 'Lead'
                        WHEN newp.status = 1 THEN 'Active' 
                        WHEN newp.status = 2 THEN 'Inactive' 
                        WHEN newp.status = 3 THEN 'Temporary Inactive'                             
                        WHEN newp.status = 6 THEN 'Prospect'
                        WHEN newp.status = 9 THEN 'Contact'
                        ELSE ''
                END AS "Appointment outcome"  
                ,t2.status AS "CRM Task Status"
                ,newp.status
        FROM
                bookings b
        JOIN 
                participations part 
                on b.id = part.booking_id
                AND b.center = part.booking_center
        JOIN 
                persons p 
                on p.id = part.participant_id
                AND p.center = part.participant_center
        JOIN
                persons newp
                ON p.current_person_center = newp.center
                AND p.current_person_id = newp.id        
        JOIN 
                person_ext_attrs peeaEmail
                ON peeaEmail.personcenter = newp.center
                AND peeaEmail.personid = newp.id
                AND peeaEmail.name = '_eClub_Email'
        JOIN 
                person_ext_attrs peeaMobile
                ON peeaMobile.personcenter = newp.center
                AND peeaMobile.personid = newp.id
                AND peeaMobile.name = '_eClub_PhoneSMS'
        JOIN    
                params 
                ON params.CENTER_ID = b.center
        JOIN 
                activity ac 
                ON b.activity= ac.id
        JOIN
                activities a
                ON a.id = ac.id           
        JOIN 
                activity_group ag
                ON ac.activity_group_id = ag.id
        JOIN 
                staff_usage su
                ON su.booking_center = b.center 
                AND su.booking_id = b.id
                AND su.state = 'ACTIVE'     
        LEFT JOIN
                task t2
                ON t2.person_center = newp.center 
                AND t2.person_id = newp.id  
        WHERE
                p.status = 5
                AND
                a.activity in (:activityname)
                AND 
                b.center in (:scope)
                AND 
                b.starttime BETWEEN params.FromDate AND params.ToDate
                AND 
                b.state != 'CANCELLED' 
        )t                
                          
WHERE
	t.status in (:status)