SELECT 
        c.shortname AS "Club"
        ,p.center ||'p'||p.id AS "PersonID"
        ,p.external_id AS "External ID"
	,s.center || 'ss' || s.id AS "Subscription ID"
        ,srp.start_date AS "Free Period Start Date"
        ,srp.end_date AS "Free Period Stop Date"
        ,(srp.end_date - srp.start_date)+1 AS "Free Period Days"
        ,longtodateC(srp.entry_time,srp.subscription_center) AS "Free Period Entry Time"    
        ,srp.text "Free Period Comment"
        ,emp_name.fullname as "Free Period Created By"
        ,s.start_date AS "Subscription Start Date"
        ,s.end_date AS "Subscription Stop Date"
        ,s.billed_until_date AS "Subscription Billed Until Date"
FROM
        subscription_reduced_period srp
JOIN
        subscriptions s
        ON s.center = srp.subscription_center
        AND s.id = srp.subscription_id
JOIN
        products pr
        ON s.subscriptiontype_center = pr.center
        AND s.subscriptiontype_id = pr.id
JOIN
        persons p
        ON p.center = s.owner_center
        AND p.id = s.owner_id
JOIN
        employees e
        ON srp.employee_center = e.center
        AND srp.employee_id = e.id
JOIN
        persons emp_name
        ON emp_name.center = e.personcenter and emp_name.id = e.personid
JOIN
        centers c
        ON C.id = srp.subscription_center
WHERE
        srp.type != 'FREEZE'
        AND
        srp.state != 'CANCELLED'
        AND 
	p.center in (:Scope)
	AND
	srp.end_date >= Current_date
	