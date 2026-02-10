-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2799
WITH PARAMS AS
(
        SELECT
                TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') AS today,
                c.id AS center_id
        FROM
                leejam.centers c
)
SELECT
        t1.center ||'p'|| t1.id AS "Person ID"
        ,t1."External ID"
        ,t1."Subscription ID"
        ,t1."Subscription Name"
        ,t1."First Name"
        ,t1."Last Name"
        ,t1."Club Name"
        ,t1."Freeze Start Date"
        ,t1."Freeze End Date"                    
        ,t1."Freeze Reason"
        ,t1."Processed on"
        ,t1."Processed by Employee ID"
        ,t1."Processed by Employee Name"
        ,t1.name AS "Freeze Name"
        ,t1.price AS "Freeze Price"
FROM
(
        SELECT
                p.center 
                ,p.id
                ,p.external_id AS "External ID"
                ,s.center || 'ss' || s.id AS "Subscription ID"
                ,prod.name AS "Subscription Name"
                ,p.firstname AS "First Name"
                ,p.lastname AS "Last Name"
                ,c.shortname AS "Club Name"
                ,sf.start_date AS "Freeze Start Date"
                ,sf.end_date AS "Freeze End Date"
                ,sf.type AS "Freeze Type"
                ,sf.text AS "Freeze Reason"
                ,longtodateC(sf.entry_time,sf.subscription_center) AS "Processed on"
                ,emp.center ||'emp'|| emp.id AS "Processed by Employee ID"
                ,empp.fullname AS "Processed by Employee Name"
                ,prod.globalid
                ,freeze_prod.name
                ,freeze_prod.price
                
        FROM
                leejam.persons p
        JOIN
                leejam.subscriptions s
                ON p.center = s.owner_center
                AND p.id = s.owner_id 
        JOIN
                PARAMS par
                ON par.center_id = s.center
        JOIN
                leejam.subscription_freeze_period sf
                ON sf.subscription_center = s.center
                AND sf.subscription_id = s.id
                AND sf.state != 'CANCELLED'
                AND sf.end_date >= par.today      
        JOIN
                leejam.centers c 
                ON c.id = p.center
        JOIN
                leejam.employees emp
                ON emp.center = sf.employee_center
                AND emp.id = sf.employee_id
        JOIN
                leejam.persons empp
                ON empp.center = emp.personcenter
                AND empp.id = emp.personid 
        JOIN
                leejam.subscriptiontypes st
        ON
                st.center = s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
        JOIN
                leejam.products prod
        ON
                prod.center = st.center
                AND prod.id = st.id   
        LEFT JOIN
                leejam.products freeze_prod
        ON
                st.freezestartupproduct_center = freeze_prod.center
                AND st.freezestartupproduct_id = freeze_prod.id
        WHERE
                p.center in (:Scope)  
)t1