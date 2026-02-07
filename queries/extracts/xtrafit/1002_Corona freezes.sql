SELECT
        p.center ||'p'|| p.id AS "Person ID"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,bi_decode_field('PERSONS', 'STATUS', p.status) AS "Person Status"
        ,c.shortname AS "Club Name"
        ,sf.start_date AS "Freeze Start Date"
        ,sf.end_date AS "Freeze End Date"
        ,sf.text AS "Freeze reason"    
        ,sf.type AS "Freeze Type"
        ,longtodateC(sf.entry_time,sf.subscription_center) AS "Processed on"
        ,emp.center ||'emp'|| emp.id AS "Processed by Employee ID"
        ,empp.fullname AS "Processed by Employee Name"
FROM
        persons p
JOIN
        subscriptions s
        ON p.center = s.owner_center
        AND p.id = s.owner_id
        AND s.state in (2,4,7,8) 
JOIN
        subscription_freeze_period sf
        ON sf.subscription_center = s.center
        AND sf.subscription_id = s.id
        AND sf.state != 'CANCELLED'
        AND sf.text = 'Corona'
            
JOIN
        centers c 
        ON c.id = p.center
JOIN
        employees emp
        ON emp.center = sf.employee_center
        AND emp.id = sf.employee_id
JOIN
        persons empp
        ON empp.center = emp.personcenter
        AND empp.id = emp.personid     
       

             