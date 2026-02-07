WITH ranked_schedules AS (
  SELECT
    ROW_NUMBER() OVER (PARTITION BY subscription_price.subscription_id ORDER BY subscription_price.entry_time DESC) AS rn,
*
  FROM subscription_price
  WHERE subscription_price.subscription_id IN (
    SELECT sp.subscription_id
    FROM subscription_price sp
    JOIN subscriptions s ON sp.subscription_id = s.id AND s.state in  (2,4)
    WHERE s.center = (:Scope) AND sp.to_date IS NOT NULL AND sp.to_date >= CURRENT_DATE  --and subscription_id = '198ss125602'
  ) and cancelled <> 'true'
)
SELECT
rs.subscription_id,s.OWNER_CENTER||'ss'||s.id,
  MAX(CASE WHEN rs.rn = 2  THEN rs.price END) AS price, -- 14.99
  MAX(CASE WHEN rs.rn = 1  THEN rs.price END) AS new_price, -- 16.99
  MAX(CASE WHEN rs.rn = 1 THEN rs.from_date END) AS change_date -- 2024-11-18
FROM ranked_schedules rs inner join subscriptions s on rs.subscription_id = s.id AND s.state in  (2,4)
WHERE s.center = (:Scope) AND rs.to_date IS NOT NULL AND rs.to_date >= CURRENT_DATE--where subscription_id = '198ss161601'
GROUP BY rs.subscription_id,s.OWNER_CENTER||'ss'||s.id