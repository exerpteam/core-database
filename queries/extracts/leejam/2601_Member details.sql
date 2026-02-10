-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
        p.center ||'p'|| p.id AS "Person id"
        ,p.firstname AS "First name"
        ,p.lastname AS "Last name"
        ,CASE p.persontype
                WHEN 0 THEN 'PRIVATE'
                WHEN 1 THEN 'STUDENT'
                WHEN 2 THEN 'STAFF'
                WHEN 3 THEN 'FRIEND'
                WHEN 4 THEN 'CORPORATE'
                WHEN 5 THEN 'ONEMANCORPORATE'
                WHEN 6 THEN 'FAMILY'
                WHEN 7 THEN 'SENIOR'
                WHEN 8 THEN 'GUEST'
                WHEN 9 THEN 'CHILD'
                WHEN 10 THEN 'EXTERNAL STAFF'		
                ELSE 'UNKNOWN'
        END AS "Person type"
        ,CASE p.status
                WHEN 0 THEN 'Lead'
                WHEN 1 THEN 'Active'
                WHEN 2 THEN 'Inactive'
                WHEN 3 THEN 'Temporary Inactive'
                WHEN 4 THEN 'Transferred'
                WHEN 5 THEN 'Duplicate'
                WHEN 6 THEN 'Prospect'
                WHEN 7 THEN 'Deleted'
                WHEN 8 THEN 'Anonymized'
                WHEN 9 THEN 'Contact'
                ELSE 'UNKNOWN'
        END AS "Person status"
        ,cp.center ||'p'|| cp.id AS "Company id"
        ,cp.fullname AS "Company name"
        ,cag.center||'p'||cag.id||'rpt'||cag.subid AS "Agreement id"
        ,cag.name AS "Agreement name"
        ,pro.name AS "Subscription name"
        ,CASE s.state
                WHEN 2 THEN 'ACTIVE' 
                WHEN 4 THEN 'FROZEN' 
                WHEN 7 THEN 'WINDOW' 
                WHEN 8 THEN 'CREATED' 
                ELSE 'Undefined' 
        END AS "Subscription status"
        ,CASE s.sub_state 
                WHEN 1 THEN 'NONE' 
                WHEN 2 THEN 'AWAITING_ACTIVATION' 
                WHEN 3 THEN 'UPGRADED' 
                WHEN 4 THEN 'DOWNGRADED' 
                WHEN 5 THEN 'EXTENDED' 
                WHEN 6 THEN 'TRANSFERRED' 
                WHEN 7 THEN 'REGRETTED' 
                WHEN 8 THEN 'CANCELLED' 
                WHEN 9 THEN 'BLOCKED' 
                WHEN 10 THEN 'CHANGED' 
                ELSE 'Undefined' 
        END AS "Subscription sub - state"
        ,s.start_date AS "Subscription start date"
        ,s.end_date AS "Subscription end date"
FROM
        leejam.persons p
LEFT JOIN
        leejam.subscriptions s
                ON s.owner_center = p.center
                AND s.owner_id = p.id
                AND s.state NOT IN (3,5,9,10)
LEFT JOIN
        leejam.subscriptiontypes st
                ON s.subscriptiontype_center = st.center
                AND s.subscriptiontype_id = st.id
LEFT JOIN
        leejam.products pro
                ON st.center = pro.center
                AND st.id = pro.id 
LEFT JOIN
        leejam.relatives comp_rel
                ON comp_rel.center = p.center
                AND comp_rel.id = p.id
                AND comp_rel.rtype = 3
                AND comp_rel.status = 1
LEFT JOIN
        leejam.companyagreements cag
                ON cag.center = comp_rel.relativecenter
                AND cag.id = comp_rel.relativeid
                AND cag.subid = comp_rel.relativesubid  
LEFT JOIN
        leejam.persons cp
                ON cp.center = cag.center
                AND cp.id = cag.id
WHERE
        p.center||'p'||p.id IN (:PersonID)
                        
                       
