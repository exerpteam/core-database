-- This is the version from 2026-02-05
--  
SELECT
  TO_CHAR(longtodate(s.CREATION_TIME), 'DD-MM-YYYY') AS creation_date,
  COUNT(DISTINCT p.center || 'p' || p.id) AS sales_count
FROM
  persons p
  JOIN subscriptions s ON s.owner_center = p.center
  AND s.owner_id = p.id
  JOIN products pr ON pr.center = s.subscriptiontype_center
  AND pr.id = s.subscriptiontype_id
WHERE
  p.center = 211
  AND longtodate(s.CREATION_TIME) >= TO_DATE('07-09-2024', 'DD-MM-YYYY')
  AND longtodate(s.CREATION_TIME) <= CURRENT_DATE
GROUP BY
  TO_CHAR(longtodate(s.CREATION_TIME), 'DD-MM-YYYY')

UNION ALL

SELECT
  'TOTAL' AS creation_date,
  COUNT(DISTINCT p.center || 'p' || p.id) AS sales_count
FROM
  persons p
  JOIN subscriptions s ON s.owner_center = p.center
  AND s.owner_id = p.id
  JOIN products pr ON pr.center = s.subscriptiontype_center
  AND pr.id = s.subscriptiontype_id
WHERE
  p.center = 211
  AND longtodate(s.CREATION_TIME) >= TO_DATE('07-09-2024', 'DD-MM-YYYY')
  AND longtodate(s.CREATION_TIME) <= CURRENT_DATE

ORDER BY
  creation_date
