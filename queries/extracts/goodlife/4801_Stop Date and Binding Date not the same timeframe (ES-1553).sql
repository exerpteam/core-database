-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        s.owner_center || 'p' || s.owner_id AS "Person ID",
        s.center || 'ss' || s.id AS "Subscription ID",
        s.binding_end_date AS "Binding End Date",
        s.end_date AS "Subscription Stop Date",
        (CASE s.state
                WHEN 2 THEN 'ACTIVE'
                WHEN 3 THEN 'ENDED'
                WHEN 4 THEN 'FROZEN'
                WHEN 7 THEN 'WINDOW'
                WHEN 8 THEN 'CREATED'
                ELSE 'UNKNOWN'
        END) AS "Subscription State",
        (CASE s.sub_state
                WHEN 1 THEN 'NONE'
                WHEN 3 THEN 'UPGRADED'
                WHEN 4 THEN 'DOWNGRADED'
                WHEN 5 THEN 'EXTENDED'
                WHEN 6 THEN 'TRANSFERRED'
                WHEN 7 THEN 'REGRETTED'
                WHEN 8 THEN 'CANCELLED'
                WHEN 9 THEN 'BLOCKED'
                WHEN 10 THEN 'CHANGED'
                ELSE 'UNKNOWN'
        END) AS "Subscription Sub-State"
FROM goodlife.subscriptions s
WHERE s.end_date IS NOT NULL
AND s.binding_end_date > s.end_date