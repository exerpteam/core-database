-- The extract is extracted from Exerp on 2026-02-08
--  
-- THREE ACCOUNT TYPES: Payment(4), External Debt(5), Installment(6)

-- PAYMENT ACCOUNT
SELECT
    c.name AS "Club Name",
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    ar.balance AS "Account Balance",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transfered'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS "Person Status",
    SUM(art.unsettled_amount) AS "Overdue/Outstanding Amount",
    CASE  
        WHEN pag.payment_cycle_config_id = 401 THEN 'Small billing'
        WHEN pag.payment_cycle_config_id = 1 THEN 'Big billing'
        ELSE 'FF_Invoice'
    END AS "Payment Cycle",
    'Payment Account' AS "Account Type",
    CASE
        WHEN pea.txtvalue ILIKE 'yes%' THEN 'Yes'
        WHEN pea.txtvalue ILIKE 'no%'  THEN 'No'
        ELSE 'No'
    END AS "eCollect"
FROM persons p
JOIN centers c
  ON c.id = p.center
JOIN account_receivables ar 
  ON p.center = ar.customercenter 
 AND p.id     = ar.customerid 
 AND ar.ar_type = 4                     -- ✅ PAYMENT
 AND ar.balance != 0 
LEFT JOIN ar_trans art 
  ON art.center = ar.center 
 AND art.id     = ar.id
 AND art.status != 'CLOSED'
 AND art.due_date < current_date  
LEFT JOIN payment_accounts pac 
  ON pac.center = ar.center 
 AND pac.id     = ar.id
LEFT JOIN payment_agreements pag 
  ON pac.active_agr_center = pag.center 
 AND pac.active_agr_id     = pag.id 
 AND pac.active_agr_subid  = pag.subid
LEFT JOIN person_ext_attrs pea
  ON pea.personcenter = p.center
 AND pea.personid     = p.id
 AND pea.name         = 'eCollect'
WHERE p.center IN (:Scope)
GROUP BY
  c.name, p.center, p.id, p.external_id, p.firstname, p.lastname, ar.balance, p.status, pag.payment_cycle_config_id, pea.txtvalue

UNION ALL

-- EXTERNAL DEBT ACCOUNT
SELECT
    c.name AS "Club Name",
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    ar.balance AS "Account Balance",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transfered'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS "Person Status",
    NULL AS "Overdue/Outstanding Amount",
    NULL AS "Payment Cycle",
    'External Debt Account' AS "Account Type",
    CASE
        WHEN pea.txtvalue ILIKE 'yes%' THEN 'Yes'
        WHEN pea.txtvalue ILIKE 'no%'  THEN 'No'
        ELSE 'No'
    END AS "eCollect"
FROM persons p
JOIN centers c
  ON c.id = p.center
JOIN account_receivables ar 
  ON p.center = ar.customercenter 
 AND p.id     = ar.customerid 
 AND ar.ar_type = 5                     -- ✅ EXTERNAL DEBT
 AND ar.balance != 0
LEFT JOIN person_ext_attrs pea
  ON pea.personcenter = p.center
 AND pea.personid     = p.id
 AND pea.name         = 'eCollect'
WHERE p.center IN (:Scope)

UNION ALL

-- INSTALLMENT PLAN ACCOUNT
SELECT
    c.name AS "Club Name",
    p.center || 'p' || p.id AS "Person ID",
    p.external_id AS "External ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    ar.balance AS "Account Balance",
    CASE
        WHEN p.status = 0 THEN 'Lead'
        WHEN p.status = 1 THEN 'Active'
        WHEN p.status = 2 THEN 'Inactive'
        WHEN p.status = 3 THEN 'Temporary Inactive'
        WHEN p.status = 4 THEN 'Transfered'
        WHEN p.status = 5 THEN 'Duplicate'
        WHEN p.status = 6 THEN 'Prospect'
        WHEN p.status = 7 THEN 'Deleted'
        WHEN p.status = 8 THEN 'Anonymized'
        WHEN p.status = 9 THEN 'Contact'
        ELSE 'Unknown'
    END AS "Person Status",
    SUM(CASE 
          WHEN art.status != 'CLOSED' AND art.due_date < current_date 
          THEN COALESCE(art.unsettled_amount,0) 
          ELSE 0 
        END) AS "Overdue/Outstanding Amount",
    NULL AS "Payment Cycle",
    'Installment Account' AS "Account Type",
    CASE
        WHEN pea.txtvalue ILIKE 'yes%' THEN 'Yes'
        WHEN pea.txtvalue ILIKE 'no%'  THEN 'No'
        ELSE 'No'
    END AS "eCollect"
FROM persons p
JOIN centers c
  ON c.id = p.center
JOIN account_receivables ar 
  ON p.center = ar.customercenter 
 AND p.id     = ar.customerid 
 AND ar.ar_type = 6                     -- ✅ INSTALLMENT
 AND ar.balance != 0 
LEFT JOIN ar_trans art 
  ON art.center = ar.center 
 AND art.id     = ar.id
LEFT JOIN person_ext_attrs pea
  ON pea.personcenter = p.center
 AND pea.personid     = p.id
 AND pea.name         = 'eCollect'
WHERE p.center IN (:Scope)
GROUP BY
  c.name, p.center, p.id, p.external_id, p.firstname, p.lastname, ar.balance, p.status, pea.txtvalue;
