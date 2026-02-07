WITH params AS (
    SELECT
        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS center_id,
        CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM centers c
),

filtered_invoices AS (
    SELECT *
    FROM fernwood.invoices inv
    JOIN params ON inv.center = params.center_id
    WHERE inv.trans_time BETWEEN params.FromDate AND params.ToDate
      AND inv.center IN (:Scope)
),

filtered_credit_notes AS (
    SELECT *
    FROM fernwood.credit_notes cn
    JOIN params ON cn.center = params.center_id
    WHERE cn.trans_time BETWEEN params.FromDate AND params.ToDate
      AND cn.center IN (:Scope)
),

filtered_account_trans AS (
    SELECT *
    FROM fernwood.account_trans act
    JOIN params ON act.center = params.center_id
    WHERE act.trans_time BETWEEN params.FromDate AND params.ToDate
      AND act.center IN (:Scope)
),

invoice_data AS (
    SELECT 
        inv.center || 'inv' || inv.id AS "Transaction No",
        longtodatec(inv.trans_time, inv.center) AS "Date",
        -invl.total_amount AS "Amount",
        COALESCE(income.external_id || '-' || income.name, credit.external_id || '-' || credit.name) AS "Cost Center",
        inv.payer_center || 'p' || inv.payer_id AS "Person ID",
        c.name AS "Club Name",
        COALESCE(art.text, invl.text) AS "Description",
        CASE
            WHEN inv.paysessionid IS NOT NULL THEN 'cash register'
            WHEN ar.ar_type = 1 THEN 'Cash account'
            WHEN ar.ar_type = 4 THEN 'Payment account'
            WHEN ar.ar_type = 5 THEN 'Debt collection account'
            WHEN ar.ar_type = 6 THEN 'Installment account'
        END AS "Account",
        CASE WHEN invl.installment_plan_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS "Paid with Installment"
    FROM filtered_invoices inv
    JOIN fernwood.invoice_lines_mt invl ON inv.center = invl.center AND inv.id = invl.id
    LEFT JOIN fernwood.products prod ON prod.center = invl.productcenter AND prod.id = invl.productid
    LEFT JOIN fernwood.masterproductregister mpr ON mpr.scope_id = prod.center AND mpr.globalid = prod.globalid
    LEFT JOIN fernwood.product_account_configurations pac ON pac.id = mpr.product_account_config_id
    LEFT JOIN fernwood.accounts income ON income.globalid = pac.sales_account_globalid AND prod.center = income.center
    LEFT JOIN fernwood.account_trans act ON act.center = invl.account_trans_center AND act.id = invl.account_trans_id AND act.subid = invl.account_trans_subid
    LEFT JOIN fernwood.ar_trans art ON inv.center = art.ref_center AND inv.id = art.ref_id AND art.ref_type = 'INVOICE'
    LEFT JOIN fernwood.account_receivables ar ON ar.center = art.center AND ar.id = art.id
    LEFT JOIN fernwood.accounts credit ON credit.center = act.credit_accountcenter AND credit.id = act.credit_accountid
    JOIN fernwood.centers c ON c.id = inv.center
    WHERE invl.installment_plan_id IS NULL
),

credit_note_data AS (
    SELECT 
        cn.center || 'cred' || cn.id AS "Transaction No",
        longtodatec(cn.trans_time, cn.center) AS "Date",
        cnl.total_amount AS "Amount",
        COALESCE(income.external_id || '-' || income.name, debit.external_id || '-' || debit.name) AS "Cost Center",
        cnl.person_center || 'p' || cnl.person_id AS "Person ID",
        c.name AS "Club Name",
        COALESCE(art.text, cnl.text) AS "Description",
        CASE
            WHEN cn.paysessionid IS NOT NULL THEN 'cash register'
            WHEN ar.ar_type = 1 THEN 'Cash account'
            WHEN ar.ar_type = 4 THEN 'Payment account'
            WHEN ar.ar_type = 5 THEN 'Debt collection account'
            WHEN ar.ar_type = 6 THEN 'Installment account'
        END AS "Account",
        CASE WHEN cnl.installment_plan_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS "Paid with Installment"
    FROM filtered_credit_notes cn
    JOIN fernwood.credit_note_lines_mt cnl ON cn.center = cnl.center AND cn.id = cnl.id
    LEFT JOIN fernwood.products prod ON prod.center = cnl.productcenter AND prod.id = cnl.productid
    LEFT JOIN fernwood.masterproductregister mpr ON mpr.scope_id = prod.center AND mpr.globalid = prod.globalid
    LEFT JOIN fernwood.product_account_configurations pac ON pac.id = mpr.product_account_config_id
    LEFT JOIN fernwood.accounts income ON income.globalid = pac.sales_account_globalid AND prod.center = income.center
    LEFT JOIN fernwood.account_trans act ON act.center = cnl.account_trans_center AND act.id = cnl.account_trans_id AND act.subid = cnl.account_trans_subid
    LEFT JOIN fernwood.ar_trans art ON cn.center = art.ref_center AND cn.id = art.ref_id AND art.ref_type = 'CREDIT_NOTE'
    LEFT JOIN fernwood.account_receivables ar ON ar.center = art.center AND ar.id = art.id
    LEFT JOIN fernwood.accounts debit ON debit.center = act.debit_accountcenter AND debit.id = act.debit_accountid
    JOIN fernwood.centers c ON c.id = cn.center
),

account_trans_data AS (
    SELECT 
        act.center || 'acc' || act.id || 'tr' || act.subid AS "Transaction No",
        longtodatec(act.trans_time, act.center) AS "Date",
        art.amount AS "Amount",
        CASE WHEN collected = 3 THEN debit.external_id || '-' || debit.name ELSE credit.external_id || '-' || credit.name END AS "Cost Center",
        ar.customercenter || 'p' || ar.customerid AS "Person ID",
        c.name AS "Club Name",
        art.text AS "Description",
        CASE
            WHEN ar.ar_type = 1 THEN 'Cash account'
            WHEN ar.ar_type = 4 THEN 'Payment account'
            WHEN ar.ar_type = 5 THEN 'Debt collection account'
            WHEN ar.ar_type = 6 THEN 'Installment account'
        END AS "Account",
        'N/A' AS "Paid with Installment"
    FROM filtered_account_trans act
    JOIN fernwood.ar_trans art ON act.center = art.ref_center AND act.id = art.ref_id AND act.subid = art.ref_subid AND art.ref_type = 'ACCOUNT_TRANS'
    JOIN fernwood.accounts credit ON credit.center = act.credit_accountcenter AND credit.id = act.credit_accountid
    JOIN fernwood.accounts debit ON debit.center = act.debit_accountcenter AND debit.id = act.debit_accountid
    JOIN fernwood.centers c ON c.id = act.center
    JOIN fernwood.account_receivables ar ON ar.center = art.center AND ar.id = art.id AND ar.ar_type != 6
)

SELECT
    t."Transaction No",
    t."Date",
    ROUND(t."Amount", 2) AS "Total Inclusive GST",
    ROUND(t."Amount" / 1.1, 2) AS "Total Exclusive GST",
    t."Cost Center",
    t."Club Name",
    t."Person ID",
    t."Description",
    t."Account",
    t."Paid with Installment"
FROM (
    SELECT * FROM invoice_data
    UNION ALL
    SELECT * FROM credit_note_data
    UNION ALL
    SELECT * FROM account_trans_data
) t
WHERE
    t."Cost Center" IN ('02.00.4110-Income Hypoxi', '103.4110-Income Hypoxi', '130.4110-Income Hypoxi',
                         '145.4110-Income Hypoxi', '146.4110-Income Hypoxi', '158.4110-Income Hypoxi', '41107-Income Hypoxi')
  AND t."Cost Center" NOT IN ('02.00.1200-Bank account: EFT', '02.00.1212.1-Account Receivables: EFT account (persons)',
                               '02.00.1280.4-Cash register interim', '02.00.1281-Account Receivables: Cash account',
                               '02.00.1282.1-Account Receivables: External debt account', '02.00.1283-Account Receivables: Installment plan account',
                               '02.00.1200.1-Bank account: credit card', '02.00.1240.1-Inventory Adjustment')
  AND (t."Paid with Installment" = 'No' OR t."Paid with Installment" = 'N/A' OR t."Transaction No" LIKE 'cred%' OR t."Transaction No" LIKE 'PartialCreditNote%')
ORDER BY t."Date", t."Transaction No";