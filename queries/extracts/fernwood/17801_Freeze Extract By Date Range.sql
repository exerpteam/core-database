SELECT
        p.center ||'p'|| p.id AS "Person ID"
        ,p.external_id AS "External ID"
        ,s.center || 'ss' || s.id AS "Subscription ID"
        ,prod.name AS "Subscription Name"
        ,p.firstname AS "First Name"
        ,p.lastname AS "Last Name"
        ,bi_decode_field('PERSONS', 'STATUS', p.status) AS "Person Status"
        ,c.shortname AS "Club Name"
        ,sf.start_date AS "Freeze Start Date"
        ,sf.end_date AS "Freeze End Date"
        ,sf.type AS "Freeze Type"
        ,sf.text AS "Freeze Reason"
        ,longtodateC(sf.entry_time,sf.subscription_center) AS "Processed on"
        ,emp.center ||'emp'|| emp.id AS "Processed by Employee ID"
        ,empp.fullname AS "Processed by Employee Name"
FROM
        persons p
JOIN
        subscriptions s
        ON p.center = s.owner_center
        AND p.id = s.owner_id
        AND s.state in (1,2,3,4,5,6,7,8,9) 
JOIN
        subscription_freeze_period sf
        ON sf.subscription_center = s.center
        AND sf.subscription_id = s.id
        AND sf.state != 'CANCELLED'   
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
JOIN
        SUBSCRIPTIONTYPES st
ON
        st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
        PRODUCTS prod
ON
        prod.CENTER = st.CENTER
        AND prod.ID = st.ID
WHERE
        p.center in (:Scope)  
        AND
        (
	(sf.start_date Between :FromDate AND :ToDate)
	OR
	(sf.end_date Between :FromDate AND :ToDate)
	OR
	(sf.start_date < :FromDate AND sf.end_date > :ToDate)
	)      