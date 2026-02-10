-- The extract is extracted from Exerp on 2026-02-08
--  
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
        ,lastvisit.LastVisit AS "Last Visit Date"
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
		AND sf.end_date >= current_date      
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
        ON st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
        AND st.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
        PRODUCTS prod
        ON prod.CENTER = st.CENTER
        AND prod.ID = st.ID
LEFT JOIN
        (
        SELECT
                ck.person_center
                ,ck.person_id
                ,longtodate(max(ck.checkin_time)) AS LastVisit
        FROM 
                checkins ck  
        GROUP BY
                ck.person_center
                ,ck.person_id
        )lastvisit
        ON lastvisit.person_center = p.center
        AND lastvisit.person_id = p.id                                
WHERE
        p.center in (:Scope)                                       

		