-- The extract is extracted from Exerp on 2026-02-08
--  
WITH dd AS (
  SELECT
      -1::int                AS club_id,          -- DD total (no per-club split available here)
      SUM(ci.total_amount)   AS dd_collected
  FROM clearing_in ci
  WHERE ci.received_date BETWEEN DATE '2025-07-01' AND DATE '2025-07-31'
    AND ci.state = 5                                  -- success
),
cc AS (
  SELECT
      cct.center            AS club_id,
      SUM(cct.amount)       AS cc_collected
  FROM creditcardtransactions cct
  WHERE to_timestamp(cct.transtime/1000.0)
        >=  TIMESTAMP '2025-07-01'
    AND to_timestamp(cct.transtime/1000.0)
        <  TIMESTAMP '2025-08-01'
    AND (cct.transaction_state = 2 OR cct.transaction_state IS NULL)   -- success + include NULL bucket
  GROUP BY cct.center
)
SELECT
  COALESCE(dd.club_id, cc.club_id)                                       AS club_id,
  COALESCE(dd.dd_collected, 0)                                           AS dd_collected,
  COALESCE(cc.cc_collected, 0)                                           AS cc_collected,
  COALESCE(dd.dd_collected, 0) + COALESCE(cc.cc_collected, 0)            AS total_collected_july
FROM dd
FULL JOIN cc ON cc.club_id = dd.club_id
ORDER BY club_id;
