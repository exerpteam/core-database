-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        s.owner_center || 'p' || s.owner_id AS "Person id"
        ,s.owner_center AS "Person centre id"
        ,cp.name AS "Person centre name"
        ,s.center ||'ss' || s.id AS "Subscription id"
        ,s.center AS "Subscription centre id"
        ,cs.name AS "Subscription centre name"
        ,prod.name AS "Subscription name"
        ,CASE s.state
                WHEN 2 THEN 'Active'
                WHEN 4 THEN 'Frozen'
                WHEN 7 THEN 'Window'
                WHEN 8 THEN 'Created'
                ELSE 'Unknown'
        END AS "Subscription status"
        ,CASE s.SUB_STATE
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
        leejam.subscriptions s
JOIN
        leejam.centers cp
        ON cp.id = s.owner_center
JOIN
        leejam.centers cs
        ON cs.id = s.center   
JOIN
        leejam.subscriptiontypes st
        ON st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
JOIN
        leejam.products prod
        ON prod.center = st.center
        AND prod.id = st.id                      
WHERE
        s.center != s.owner_center 
        AND
        s.state in (2,4,8)  
        AND
        s.owner_center in (:PersonCenter)
		AND
		s.start_date <= CAST ((date_trunc('day', now()) + INTERVAL '1 day') AS DATE)
		
		