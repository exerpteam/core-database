-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        s.owner_center || 'p' || s.owner_id AS sub_from_owner,
        s.center || 'ss' || s.id AS sub_from_id,
        CASE s.state WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS sub_from_state,
        CASE s.sub_state WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 
                        THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS sub_from_substate,
        sto.owner_center || 'p' || sto.owner_id AS sub_to_owner,
        sto.center || 'ss' || sto.id AS sub_to_id,
        CASE sto.state WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS sub_to_state,
        CASE sto.sub_state WHEN 1 THEN 'NONE' WHEN 2 THEN 'AWAITING_ACTIVATION' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 
                        THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' ELSE 'Undefined' END AS sub_to_substate
FROM puregym_switzerland.subscriptions s
JOIN puregym_switzerland.subscription_change sc
        ON s.center = sc.old_subscription_center AND s.id = sc.old_subscription_id
JOIN puregym_switzerland.subscriptions sto
        ON sto.center = sc.new_subscription_center AND sto.id = sc.new_subscription_id
JOIN puregym_switzerland.subscriptiontypes st ON s.subscriptiontype_center = st.center AND s.subscriptiontype_id = st.id
WHERE
        sc.type = 'TYPE'
        AND st.periodcount > 1
