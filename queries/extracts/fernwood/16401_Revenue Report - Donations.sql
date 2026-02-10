-- The extract is extracted from Exerp on 2026-02-08
-- 
WITH params AS (
    SELECT
        datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS CENTER_ID,
        CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM centers c
)
SELECT 
    inv.center || 'inv' || inv.id AS "Transaction No",
    longtodatec(inv.trans_time, inv.center) AS "Date",
    -invl.total_amount AS "Amount",
    CASE
        WHEN income.name IS NOT NULL THEN income.external_id || '-' || income.name 
        ELSE credit.external_id || '-' || credit.name 
    END AS "Cost Center",
    inv.payer_center || 'p' || inv.payer_id AS "Person ID",
    c.name AS "Club Name",
    c.id AS "Club ID",
    CASE
        WHEN art.text IS NOT NULL THEN art.text
        ELSE invl.text
    END AS "Description",
    CASE
        WHEN inv.paysessionid IS NOT NULL THEN 'cash register'
        ELSE 
            CASE
                WHEN ar.ar_type = 1 THEN 'Cash account'
                WHEN ar.ar_type = 4 THEN 'Payment account'
                WHEN ar.ar_type = 5 THEN 'Debt collection account'
                WHEN ar.ar_type = 6 THEN 'Installment account'
            END                        
    END AS "Account", 
    CASE
        WHEN invl.installment_plan_id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS "Paid with Installment"
FROM invoices inv
JOIN invoice_lines_mt invl 
  ON inv.center = invl.center AND inv.id = invl.id
LEFT JOIN products prod 
  ON prod.center = invl.productcenter AND prod.id = invl.productid 
LEFT JOIN masterproductregister mpr 
  ON mpr.scope_id = prod.center AND mpr.globalid = prod.globalid
LEFT JOIN product_account_configurations pac 
  ON pac.id = mpr.product_account_config_id
LEFT JOIN accounts income 
  ON income.globalid = pac.sales_account_globalid AND prod.center = income.center
LEFT JOIN account_trans act 
  ON act.center = invl.account_trans_center 
 AND act.id = invl.account_trans_id 
 AND act.subid = invl.account_trans_subid
LEFT JOIN ar_trans art 
  ON inv.center = art.ref_center 
 AND inv.id = art.ref_id 
 AND art.ref_type = 'INVOICE'
LEFT JOIN account_receivables ar 
  ON ar.center = art.center AND ar.id = art.id
LEFT JOIN accounts credit 
  ON credit.center = act.credit_accountcenter AND credit.id = act.credit_accountid
JOIN centers c 
  ON c.id = inv.center
JOIN params 
  ON params.center_id = inv.center
WHERE inv.center IN (:Scope)
  AND inv.trans_time BETWEEN params.FromDate AND params.ToDate
  AND (
        /* Match exact combined label OR code-only on either side */
        (income.external_id || '-' || income.name = '02.00.6900-Donation Income'
         OR income.external_id = '02.00.6900')
     OR (credit.external_id || '-' || credit.name = '02.00.6900-Donation Income'
         OR credit.external_id = '02.00.6900')
      );
