-- The extract is extracted from Exerp on 2026-02-08
--  
WITH par AS MATERIALIZED (
  SELECT c.id AS center_id
  FROM centers c
  WHERE c.id IN (:Scope)
),

-- Members: Active, Temp Inactive, or Inactive (for debt check), excluding Staff
members AS MATERIALIZED (
  SELECT
      p.center        AS center_id,
      p.id            AS person_id,
      p.fullname      AS member_name,
      p.status        AS person_status,
      COALESCE(p.persontype, -1) AS person_type
  FROM persons p
  JOIN par ON par.center_id = p.center
  WHERE p.status IN (1,3,2)
    AND COALESCE(p.persontype, -1) <> 2
),

-- Paid-in-Full subscriptions (exclude these)
cash_sub AS MATERIALIZED (
  SELECT DISTINCT
      s.owner_center AS center_id,
      s.owner_id     AS person_id
  FROM subscriptions s
  JOIN subscriptiontypes st
    ON st.center = s.subscriptiontype_center
   AND st.id     = s.subscriptiontype_id
  WHERE st.st_type = 0
    AND s.state IN (2,4,8)
    AND CURRENT_DATE BETWEEN s.start_date
                         AND COALESCE(s.end_date, DATE '2999-12-31')
),

-- Members whose ONLY current subscription is "Unlimited Childcare Access"
childcare_only AS MATERIALIZED (
  SELECT
      x.owner_center AS center_id,
      x.owner_id     AS person_id
  FROM (
    SELECT
        s.owner_center,
        s.owner_id,
        COUNT(*) AS total_current,
        SUM(
          CASE
            WHEN UPPER(TRIM(prod.name)) = UPPER('Unlimited Childcare Access') THEN 1
            ELSE 0
          END
        ) AS childcare_count
    FROM subscriptions s
    JOIN subscriptiontypes st
      ON st.center = s.subscriptiontype_center
     AND st.id     = s.subscriptiontype_id
    JOIN products prod
      ON prod.center = st.center
     AND prod.id     = st.id
    WHERE s.state IN (2,4,8)
      AND CURRENT_DATE BETWEEN s.start_date
                           AND COALESCE(s.end_date, DATE '2999-12-31')
    GROUP BY s.owner_center, s.owner_id
  ) x
  WHERE x.total_current > 0
    AND x.childcare_count = x.total_current
),

-- Inactive members with negative AR balance (Payment, Installment, External)
neg_balance AS MATERIALIZED (
  SELECT DISTINCT
      ar.customercenter AS center_id,
      ar.customerid     AS person_id
  FROM account_receivables ar
  WHERE ar.ar_type IN (4,6,8)
    AND ar.balance < 0
),

-- Join AR → Payment Account → Active Agreement
ledger AS MATERIALIZED (
  SELECT
      m.center_id,
      m.person_id,
      m.member_name,
      m.person_status,
      ar.id      AS ar_id,
      pac.id     AS pac_id,
      pag.id     AS pag_id,
      pag.state  AS pag_state,
      pag.active AS pag_active,
      pag.clearinghouse
  FROM members m
  LEFT JOIN account_receivables ar
         ON ar.customercenter = m.center_id
        AND ar.customerid     = m.person_id
        AND ar.ar_type        = 4
  LEFT JOIN payment_accounts pac
         ON pac.center = ar.center
        AND pac.id     = ar.id
  LEFT JOIN payment_agreements pag
         ON pag.center = pac.active_agr_center
        AND pag.id     = pac.active_agr_id
        AND pag.subid  = pac.active_agr_subid
        AND pag.active = 'true'
),

-- Decode state → screen-style status
classified AS MATERIALIZED (
  SELECT
      l.center_id,
      l.person_id,
      l.member_name,
      l.person_status,
      l.clearinghouse,
      CASE
        WHEN l.ar_id  IS NULL THEN 'No AR (type 4)'
        WHEN l.pac_id IS NULL THEN 'No payment account'
        WHEN l.pag_id IS NULL THEN 'No agreement'
        WHEN l.pag_state = 3  THEN 'Failed'
        WHEN l.pag_state = 5  THEN 'Ended by bank'
        WHEN l.pag_state = 6  THEN 'Ended by clearing house'
        WHEN l.pag_state = 7  THEN 'Ended by debtor'
        WHEN l.pag_state = 8  THEN 'Cancelled (not sent)'
        WHEN l.pag_state = 9  THEN 'Cancelled (sent)'
        WHEN l.pag_state = 10 THEN 'Ended by creditor'
        WHEN l.pag_state = 11 THEN 'No agreement'
        WHEN l.pag_state = 12 THEN 'Cash payment (deprecated)'
        WHEN l.pag_state = 14 THEN 'Agreement information incomplete'
        WHEN l.pag_state = 17 THEN 'Signature missing'
        WHEN l.pag_state = 2  THEN 'Sent'
        WHEN l.pag_state = 4  THEN 'OK'
        WHEN l.pag_state = 16 THEN 'Agreement recreated'
        ELSE 'Check state'
      END AS status_label,
      CASE WHEN l.pag_state IN (2,4,16) THEN TRUE ELSE FALSE END AS is_valid
  FROM ledger l
)

SELECT
    c.center_id || 'p' || c.person_id AS "Person ID",
    fc.name                            AS "Club",
    c.member_name                      AS "Member Name",
    CASE c.person_status
      WHEN 1 THEN 'Active'
      WHEN 3 THEN 'Temporary Inactive'
      WHEN 2 THEN 'Inactive'
      ELSE CAST(c.person_status AS TEXT)
    END                                 AS "Member Status",
    c.status_label                      AS "Status",
    CASE c.clearinghouse
      WHEN 1 THEN 'Bank Account'
      WHEN 2 THEN 'Credit Card'
      ELSE NULL
    END                                 AS "Clearing House"
FROM classified c
LEFT JOIN centers fc
       ON fc.id = c.center_id
LEFT JOIN cash_sub cs
       ON cs.center_id = c.center_id AND cs.person_id = c.person_id
LEFT JOIN neg_balance nb
       ON nb.center_id = c.center_id AND nb.person_id = c.person_id
LEFT JOIN childcare_only uca_only
       ON uca_only.center_id = c.center_id AND uca_only.person_id = c.person_id
WHERE
      c.is_valid = FALSE
  AND cs.person_id IS NULL                         -- exclude PIF
  AND uca_only.person_id IS NULL                   -- exclude if ONLY "Unlimited Childcare Access"
  AND (
        c.person_status IN (1,3)                   -- Active or Temp Inactive
        OR (c.person_status = 2 AND nb.person_id IS NOT NULL)
      )
ORDER BY fc.name, "Person ID";