-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        p.fullname AS "Member Name"
        ,p.center ||'p'|| p.id AS "Person ID"
        ,t.status AS "Task Status"
        ,ts.name AS "Task Step"
        ,t.step_id AS "Step ID"
        ,assignee.fullname AS "Assigned To"
        ,assignee.center||'p'||assignee.id AS "Assignee Person ID"
        ,t.title AS "Task Title"
        ,t.follow_up AS "Follow-up Date"
FROM  
        task_types tt
JOIN
        tasks t
        ON t.type_id = tt.id
        AND t.status != 'CLOSED'  
JOIN    
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
WHERE
        tt.external_id = 'HYPOXI'
        AND
        p.center IN (:Scope)
        AND
        t.status IN (:Status)