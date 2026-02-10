-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        ts.name
        ,ta.name
        ,p.center||'p'||p.id as personid
        ,p.external_id
        ,t.title
        ,empp.fullname as assignee
        ,t.permanent_note
        
FROM
        tasks t                
JOIN
        task_steps ts
        ON ts.id = t.step_id            
JOIN
        persons p
        ON p.center = t.person_center
        AND p.id = t.person_id
JOIN
        task_log tl
        ON tl.task_id = t.id
JOIN
        task_actions ta
        ON ta.id = tl.task_action_id 
LEFT JOIN
        employees emp
        ON emp.center = t.asignee_center
        AND emp.id = t.asignee_id
LEFT JOIN
        persons empp
        ON empp.center = emp.personcenter
        AND empp.id = emp.personid                                   
WHERE
        P.external_id = :ExternalID    
        AND
        t.type_id = 400