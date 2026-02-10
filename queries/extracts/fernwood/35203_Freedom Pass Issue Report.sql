-- The extract is extracted from Exerp on 2026-02-08
--  
-- 8-week visit list (one row per visit) + transfer_to + AR columns, multi-center
WITH params AS (
  SELECT CURRENT_DATE::date AS today,
         (CURRENT_DATE - INTERVAL '56 days')::date AS start_date
),

-- Members in scope (Active only)
people AS (
  SELECT
      p.id,
      p.external_id,
      p.fullname,
      p.center AS home_center_id
  FROM persons p
  WHERE p.center IN (:Scope)           -- multi-center
    AND p.status = 1                   -- Active only (exclude frozen)
	AND p.persontype <> 2
),

-- Visits in window; join on BOTH keys to avoid cross-club collisions
visits AS (
  SELECT
      pe.home_center_id,
      pe.id            AS person_id,
      pe.external_id,
      pe.fullname,
      c.checkin_center AS visit_center_id,
      longtodatec(c.checkin_time, c.checkin_center) AS visit_ts
  FROM checkins c
  JOIN people  pe
    ON pe.id = c.person_id
   AND pe.home_center_id = c.person_center
  JOIN params q
    ON longtodatec(c.checkin_time, c.checkin_center)::date
       BETWEEN q.start_date AND q.today
),

-- Totals per (home_center_id, person_id)
counts AS (
  SELECT
      home_center_id,
      person_id,
      COUNT(*) AS total_visits_8w,
      SUM(CASE WHEN visit_center_id = home_center_id THEN 1 ELSE 0 END)  AS home_visits_8w,
      SUM(CASE WHEN visit_center_id <> home_center_id THEN 1 ELSE 0 END) AS other_visits_8w
  FROM visits
  GROUP BY home_center_id, person_id
),

-- Per-person, per-visited-club counts
club_counts AS (
  SELECT
      home_center_id,
      person_id,
      visit_center_id,
      COUNT(*) AS visit_count
  FROM visits
  GROUP BY home_center_id, person_id, visit_center_id
),

-- Max count among non-home clubs (per composite key)
top_other AS (
  SELECT
      home_center_id,
      person_id,
      MAX(CASE WHEN visit_center_id <> home_center_id THEN visit_count END) AS max_other_count
  FROM club_counts
  GROUP BY home_center_id, person_id
),

-- Transfer target(s): all non-home clubs tied for the max
transfer_choice AS (
  SELECT
      cc.home_center_id,
      cc.person_id,
      STRING_AGG(cz.name, ', ' ORDER BY cz.name) AS transfer_to
  FROM club_counts cc
  JOIN top_other t
    ON t.home_center_id = cc.home_center_id
   AND t.person_id       = cc.person_id
   AND cc.visit_center_id <> cc.home_center_id
   AND cc.visit_count     = t.max_other_count
  JOIN centers cz
    ON cz.id = cc.visit_center_id
  GROUP BY cc.home_center_id, cc.person_id
),

/* ------------------- AR ADD-ONS ------------------- */

/* Overdue (open + past due) for Payment (4) and External Debt (5) */
ar_overdue AS (
  SELECT
      ar.customercenter AS home_center_id,
      ar.customerid     AS person_id,
      SUM(
        CASE
          WHEN art.status <> 'CLOSED' AND art.due_date < CURRENT_DATE
          THEN COALESCE(art.unsettled_amount, 0)
          ELSE 0
        END
      ) AS overdue_debt
  FROM account_receivables ar
  LEFT JOIN ar_trans art
         ON art.center = ar.center
        AND art.id     = ar.id
  WHERE ar.ar_type IN (4,5)  -- Payment + External Debt
  GROUP BY ar.customercenter, ar.customerid
),

/* Installment balance (type 6). Use SUM in case multiple ARs exist. */
ar_installment AS (
  SELECT
      ar.customercenter AS home_center_id,
      ar.customerid     AS person_id,
      SUM(ar.balance)   AS installment_balance
  FROM account_receivables ar
  WHERE ar.ar_type = 6       -- Installment
  GROUP BY ar.customercenter, ar.customerid
),

-- ✅ Eligibility: 6+ total visits AND some single other club strictly beats home
eligible AS (
  SELECT
      c.home_center_id,
      c.person_id
  FROM counts c
  JOIN top_other t
    ON t.home_center_id = c.home_center_id
   AND t.person_id      = c.person_id
  WHERE COALESCE(t.max_other_count, 0) >= 6
    AND COALESCE(t.max_other_count, 0) > c.home_visits_8w
)

SELECT
    -- Standard formatted person id
    v.home_center_id || 'p' || v.person_id  AS person_id,
    v.external_id,
    v.fullname,
    hc.name                                  AS home_center,

    ROW_NUMBER() OVER (
      PARTITION BY v.home_center_id, v.person_id
      ORDER BY v.visit_ts
    )                                        AS visit_seq,
    vc.name                                  AS visit_center,
    v.visit_ts::date                         AS visit_date,

    tc.transfer_to                           AS transfer_to,

    -- New AR columns:
    COALESCE(aro.overdue_debt, 0)            AS overdue_debt,        -- payment + external (overdue only)
    COALESCE(ari.installment_balance, 0)     AS installment_balance  -- installment current balance
FROM visits v
JOIN eligible e
  ON e.home_center_id = v.home_center_id
 AND e.person_id      = v.person_id
JOIN centers hc ON hc.id = v.home_center_id
JOIN centers vc ON vc.id = v.visit_center_id
LEFT JOIN transfer_choice tc
       ON tc.home_center_id = v.home_center_id
      AND tc.person_id      = v.person_id
LEFT JOIN ar_overdue aro
       ON aro.home_center_id = v.home_center_id
      AND aro.person_id      = v.person_id
LEFT JOIN ar_installment ari
       ON ari.home_center_id = v.home_center_id
      AND ari.person_id      = v.person_id
ORDER BY v.home_center_id, v.fullname, visit_seq;
