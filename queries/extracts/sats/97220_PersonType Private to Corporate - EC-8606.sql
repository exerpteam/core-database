WITH params AS (
    SELECT
        dateToLongC(TO_CHAR(CURRENT_DATE - INTERVAL '1 DAY' * :daysAgo, 'YYYY-MM-DD'), c.id) AS fromDate,
        dateToLongC(TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD'), c.id) - 1 AS toDate,
        c.id AS center_id
    FROM centers c
    WHERE c.id IN (:Scope)
),
p1_persons AS (
    SELECT DISTINCT
        p1.center,
        p1.id
    FROM subscription_sales ss
    JOIN subscriptions s ON s.center = ss.subscription_center AND s.id = ss.subscription_id
    JOIN persons p ON p.center = s.owner_center AND p.id = s.owner_id
    JOIN persons p1 ON p.transfers_current_prs_center = p1.transfers_current_prs_center
                     AND p.transfers_current_prs_id = p1.transfers_current_prs_id
    JOIN params ON params.center_id = ss.subscription_center
    WHERE
        ss.sales_date BETWEEN CURRENT_DATE - INTERVAL '1 DAY' * :daysAgo AND CURRENT_DATE
        AND s.state = 2
        AND p.status = 1
        AND ss.subscription_center = params.center_id
),
filtered_state_change AS (
    SELECT
        scl1.center,
        scl1.id,
        scl1.entry_start_time AS change_time,
        scl1.stateid AS new_stateid,
        LAG(scl1.stateid) OVER (PARTITION BY scl1.center, scl1.id ORDER BY scl1.entry_start_time) AS prev_stateid
    FROM state_change_log scl1
    INNER JOIN p1_persons p1p ON scl1.center = p1p.center AND scl1.id = p1p.id
    WHERE
        scl1.entry_type = 3
        AND scl1.stateid IN (0, 4) -- Restricting states early to minimize data volume
)
SELECT 
    s.owner_center || 'p' || s.owner_id AS member_id    
FROM subscription_sales ss
JOIN subscriptions s ON s.center = ss.subscription_center AND s.id = ss.subscription_id
JOIN persons p ON p.center = s.owner_center AND p.id = s.owner_id
JOIN persons p1 ON p.transfers_current_prs_center = p1.transfers_current_prs_center 
                 AND p.transfers_current_prs_id = p1.transfers_current_prs_id
JOIN filtered_state_change scl ON scl.center = p1.center 
      AND scl.id = p1.id 
      AND scl.change_time > s.creation_time + 1000
JOIN products pr ON pr.center = s.subscriptiontype_center AND pr.id = s.subscriptiontype_id
JOIN params ON params.center_id = ss.subscription_center
WHERE 
    ss.sales_date BETWEEN CURRENT_DATE - INTERVAL '1 DAY' * :daysAgo AND CURRENT_DATE
    AND ss.subscription_center = params.center_id
    AND scl.prev_stateid = 0 -- Private
    AND scl.new_stateid = 4 -- Corporate
    AND s.state = 2
    AND p.status = 1;
