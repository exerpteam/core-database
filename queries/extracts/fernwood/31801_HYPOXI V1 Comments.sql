-- The extract is extracted from Exerp on 2026-02-08
--  
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
        ,tld.value AS "Comment"
        ,empp.fullname AS "Comment By"
        ,longtodateC(tl.entry_time,tl.employee_center) AS "Commented ON"
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
        task_log tl 
                ON t.id = tl.task_id  
LEFT JOIN
        task_log_details tld
                ON tld.task_log_id = tl.id
                AND tld.name = '_eClub_COMMENT'                             
LEFT JOIN
        persons empp
                ON empp.center = tl.employee_center
                AND empp.id = tl.employee_id
LEFT JOIN
        persons assignee
                ON assignee.center = t.asignee_center
                AND assignee.id = t.asignee_id
JOIN
        centers c
                ON c.id = t.person_center
WHERE
        t.type_id = 800
        AND
        p.center||'p'||p.id in (:PersonID)
        AND
        tld.value IS NOT NULL