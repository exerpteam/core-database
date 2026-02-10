-- The extract is extracted from Exerp on 2026-02-08
--  
WITH arrears_members AS (
    SELECT
        ar.center,
        ar.id,
        ar.customercenter,
        ar.customerid,
        ar.balance
    FROM account_receivables ar
    WHERE ar.ar_type = 4
      AND ar.balance < 0
),
payment_requests_today AS (
    SELECT DISTINCT
        p.center AS person_center,
        p.id     AS person_id
    FROM payment_requests pr
    JOIN payment_agreements pag
      ON pr.center = pag.center
     AND pr.id     = pag.id
     AND pr.agr_subid = pag.subid
    JOIN account_receivables ar
      ON pag.center = ar.center
     AND pag.id     = ar.id
    JOIN persons p
      ON ar.customercenter = p.center
     AND ar.customerid     = p.id
    WHERE pr.req_date = (now() AT TIME ZONE 'Australia/Melbourne')::date
),
latest_debt_task AS (
    SELECT
        t.id,
        t.person_center,
        t.person_id,
        t.step_id,
        t.status AS task_status,
        t.asignee_id,
        t.asignee_center,
        ROW_NUMBER() OVER (PARTITION BY t.person_center, t.person_id ORDER BY t.last_update_time DESC) AS rn
    FROM tasks t
    JOIN task_types tt
      ON tt.id = t.type_id
     AND tt.external_id = 'DM_NEW'
    WHERE t.status NOT IN ('CLOSED','DELETED')
)
SELECT
    c.name AS club,
    p.firstname || ' ' || p.lastname AS member_name,
    p.center || 'p' || p.id AS person_id,
    ar.balance AS account_balance,
    CASE
        WHEN pas.individual_deduction_day = 4  THEN 'Small Billing'
        WHEN pas.individual_deduction_day = 11 THEN 'Big Billing'
        ELSE 'Unknown'
    END AS billing_cycle,
    CASE
        WHEN pas.state = 1  THEN 'Created'
        WHEN pas.state = 2  THEN 'Sent'
        WHEN pas.state = 3  THEN 'Failed'
        WHEN pas.state = 4  THEN 'OK'
        WHEN pas.state = 5  THEN 'Ended by bank'
        WHEN pas.state = 6  THEN 'Ended by clearing house'
        WHEN pas.state = 7  THEN 'Ended by debtor'
        WHEN pas.state = 8  THEN 'Cancelled, not sent'
        WHEN pas.state = 9  THEN 'Cancelled, sent'
        WHEN pas.state = 10 THEN 'Ended, creditor'
        WHEN pas.state = 11 THEN 'No agreement (deprecated)'
        WHEN pas.state = 12 THEN 'Cash payment (deprecated)'
        WHEN pas.state = 13 THEN 'Agreement not needed (invoice payment)'
        WHEN pas.state = 14 THEN 'Incomplete info'
        WHEN pas.state = 15 THEN 'Transfer'
        WHEN pas.state = 16 THEN 'Recreated'
        WHEN pas.state = 17 THEN 'Signature missing'
        ELSE 'No Agreement'
    END AS payment_agreement_status,
    ts.name AS task_step,
    task.task_status,
    assignee.fullname AS task_assigned_to,

    /* ✅ new column added at the end */
    COALESCE((
        SELECT SUM(pr.req_amount)::numeric
        FROM payment_requests pr
        WHERE pr.req_date = (now() AT TIME ZONE 'Australia/Melbourne')::date
          AND pr.center    = pas.center
          AND pr.id        = pas.id
          AND pr.agr_subid = pas.subid
    ), 0) AS payments_today

FROM arrears_members ar
JOIN persons p
  ON p.center = ar.customercenter
 AND p.id     = ar.customerid
JOIN centers c
  ON c.id = p.center
LEFT JOIN payment_requests_today prt
  ON prt.person_center = p.center
 AND prt.person_id     = p.id
LEFT JOIN payment_accounts pac
  ON pac.center = ar.center
 AND pac.id     = ar.id
LEFT JOIN payment_agreements pas
  ON pac.active_agr_center = pas.center
 AND pac.active_agr_id     = pas.id
 AND pac.active_agr_subid  = pas.subid
LEFT JOIN latest_debt_task task
  ON task.person_center = p.center
 AND task.person_id     = p.id
 AND task.rn = 1
LEFT JOIN task_steps ts
  ON ts.id = task.step_id
LEFT JOIN persons assignee
  ON assignee.center = task.asignee_center
 AND assignee.id     = task.asignee_id
WHERE
    prt.person_id IS NULL
    AND p.center NOT IN (204,303,305,309,311,314,320,321,327,601,602,702,704)
ORDER BY
    c.name,
    member_name;
