-- The extract is extracted from Exerp on 2026-02-08
--  
WITH params AS
(
    SELECT
        datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS CENTER_ID,
        CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM
        centers c
)
SELECT 
    p.center || 'p' || p.id AS "Member Exerp ID",
    p.firstname AS "First Name",
    p.lastname AS "Last Name",
    prod.name AS "Sanction Product",
    longtodatec(inv.trans_time, inv.center) AS "Date of Charge",
    ABS(invl.total_amount) AS "Price"
FROM
    invoices inv
JOIN
    invoice_lines_mt invl ON inv.center = invl.center AND inv.id = invl.id   
LEFT JOIN    
    products prod ON prod.center = invl.productcenter AND prod.id = invl.productid 
LEFT JOIN
    masterproductregister mpr ON mpr.scope_id = prod.center AND mpr.globalid = prod.globalid
LEFT JOIN
    product_account_configurations pac ON pac.id = mpr.product_account_config_id
LEFT JOIN
    accounts income ON income.globalid = pac.sales_account_globalid AND prod.center = income.center  
LEFT JOIN
    account_trans act ON act.center = invl.account_trans_center AND act.id = invl.account_trans_id AND act.subid = invl.account_trans_subid
LEFT JOIN
    accounts credit ON credit.center = act.credit_accountcenter AND credit.id = act.credit_accountid                     
JOIN
    persons p ON p.center = inv.payer_center AND p.id = inv.payer_id
JOIN
    params ON params.center_id = inv.center       
WHERE
    inv.center IN (:Scope)
    AND inv.trans_time BETWEEN params.FromDate AND params.ToDate     
    AND (income.name = 'Sanction No Show Fee Income' OR credit.name = 'Sanction No Show Fee Income')

UNION ALL

SELECT 
    p.center || 'p' || p.id AS "Member Exerp ID",
    p.firstname AS "First Name", 
    p.lastname AS "Last Name",
    prod.name AS "Sanction Product",
    longtodatec(cn.trans_time, cn.center) AS "Date of Charge",
    cnl.total_amount AS "Price"
FROM
    credit_notes cn
JOIN
    credit_note_lines_mt cnl ON cn.center = cnl.center AND cn.id = cnl.id 
LEFT JOIN    
    products prod ON prod.center = cnl.productcenter AND prod.id = cnl.productid 
LEFT JOIN
    masterproductregister mpr ON mpr.scope_id = prod.center AND mpr.globalid = prod.globalid
LEFT JOIN
    product_account_configurations pac ON pac.id = mpr.product_account_config_id
LEFT JOIN
    accounts income ON income.globalid = pac.sales_account_globalid AND prod.center = income.center  
LEFT JOIN
    account_trans act ON act.center = cnl.account_trans_center AND act.id = cnl.account_trans_id AND act.subid = cnl.account_trans_subid
LEFT JOIN
    accounts debit ON debit.center = act.debit_accountcenter AND debit.id = act.debit_accountid 
JOIN
    persons p ON p.center = cnl.person_center AND p.id = cnl.person_id
JOIN
    params ON params.center_id = cn.center       
WHERE
    cn.center IN (:Scope)
    AND cn.trans_time BETWEEN params.FromDate AND params.ToDate 
    AND (income.name = 'Sanction No Show Fee Income' OR debit.name = 'Sanction No Show Fee Income')

ORDER BY "Date of Charge" DESC, "Last Name", "First Name";