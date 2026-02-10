-- The extract is extracted from Exerp on 2026-02-08
-- Summary form of detail report - reports should add up and totals match
WITH params AS
(
        SELECT
                datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                c.id AS CENTER_ID,
                CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
        FROM
                centers c
)
SELECT
        sum(t."Amount") AS Total
        ,t."Cost Center"
        ,t."Club ID"
        ,t."Club Name"
FROM
        (                
        SELECT 
                inv.center||'inv'||inv.id as "Transaction No"
                ,longtodatec(inv.trans_time,inv.center) AS "Date"
                ,-invl.total_amount AS "Amount"
                ,CASE
                        WHEN income.name IS NOT NULL THEN income.external_id||'-'||income.name 
                        ELSE credit.external_id||'-'||credit.name 
                END AS "Cost Center"
                ,inv.payer_center||'p'||inv.payer_id AS "Person ID"
                ,c.name AS "Club Name"
                ,c.id AS "Club ID"
                --,1 as a 
        FROM
                invoices inv
        JOIN
                invoice_lines_mt invl
                ON inv.center = invl.center
                AND inv.id = invl.id   
        LEFT JOIN    
                products prod
                ON prod.center = invl.productcenter
                AND prod.id = invl.productid 
        LEFT JOIN
                masterproductregister mpr
                ON mpr.scope_id = prod.center
                AND mpr.globalid = prod.globalid
        LEFT JOIN
                product_account_configurations pac
                ON pac.id = mpr.product_account_config_id
        LEFT JOIN
                accounts income
                ON income.globalid = pac.sales_account_globalid
                AND prod.center = income.center  
        LEFT JOIN
                account_trans act
                ON act.center = invl.account_trans_center
                AND act.id = invl.account_trans_id
                AND act.subid = invl.account_trans_subid
        LEFT JOIN
                ar_trans art
                ON  inv.center = art.ref_center
                AND inv.id = art.ref_id
                AND art.ref_type = 'INVOICE'           
        LEFT JOIN
                accounts credit
                ON credit.center = act.credit_accountcenter
                AND credit.id = act.credit_accountid                     
        JOIN
                centers c
                ON c.id = inv.center                          
        JOIN
                params
                ON params.center_id = inv.center       
        WHERE
                inv.center IN (:Scope)
                AND
                inv.trans_time BETWEEN params.FromDate AND params.ToDate     
        UNION ALL
        SELECT 
                cn.center||'cred'||cn.id as "Transaction No"
                ,longtodatec(cn.trans_time,cn.center) AS "Date"
                ,cnl.total_amount AS "Amount"
                ,CASE
                        WHEN income.name IS NOT NULL THEN income.external_id||'-'||income.name 
                        ELSE debit.external_id||'-'||debit.name 
                END AS "Cost Center"
                ,cnl.person_center||'p'||cnl.person_id AS "Person ID"
                ,c.name AS "Club Name"
                ,c.id AS "Club ID"
                --,2 as a         
        FROM
                credit_notes cn
        JOIN
                credit_note_lines_mt cnl
                ON cn.center = cnl.center
                AND cn.id = cnl.id 
        LEFT JOIN    
                products prod
                ON prod.center = cnl.productcenter
                AND prod.id = cnl.productid 
        LEFT JOIN
                masterproductregister mpr
                ON mpr.scope_id = prod.center
                AND mpr.globalid = prod.globalid
        LEFT JOIN
                product_account_configurations pac
                ON pac.id = mpr.product_account_config_id
        LEFT JOIN
                accounts income
                ON income.globalid = pac.sales_account_globalid
                AND prod.center = income.center  
        LEFT JOIN
                account_trans act
                ON act.center = cnl.account_trans_center
                AND act.id = cnl.account_trans_id
                AND act.subid = cnl.account_trans_subid
        LEFT JOIN
                ar_trans art
                ON  cn.center = art.ref_center
                AND cn.id = art.ref_id
                AND art.ref_type = 'CREDIT_NOTE'         
        LEFT JOIN
                accounts debit
                ON debit.center = act.debit_accountcenter
                AND debit.id = act.debit_accountid 
        JOIN
                centers c
                ON c.id = cn.center                                  
        JOIN
                params
                ON params.center_id = cn.center       
        WHERE
                cn.center IN (:Scope)
                AND
                cn.trans_time BETWEEN params.FromDate AND params.ToDate 
        UNION ALL
        SELECT 
                act.center||'acc'||act.id||'tr'||act.subid as "Transaction No"
                ,longtodatec(act.trans_time,act.center) AS "Date"
                ,art.amount AS "Amount"
                ,CASE
                        WHEN collected = 3 THEN debit.external_id||'-'||debit.name 
                        ELSE credit.external_id||'-'||credit.name 
                END AS "Cost Center"
                ,CASE
                        WHEN pr.customercenter IS NOT NULL THEN pr.customercenter||'p'||pr.customerid 
                        ELSE act.info 
                END AS "Person ID"
                ,c.name AS "Club Name"
                ,c.id AS "Club ID"
                --,3 as a      
        FROM
                account_trans act
        JOIN
                ar_trans art
                ON  act.center = art.ref_center
                AND act.id = art.ref_id
                AND act.subid = art.ref_subid
                AND art.ref_type = 'ACCOUNT_TRANS'
        JOIN
                accounts credit
                ON credit.center = act.credit_accountcenter
                AND credit.id = act.credit_accountid
        JOIN
                accounts debit
                ON debit.center = act.debit_accountcenter
                AND debit.id = act.debit_accountid 
        JOIN
                centers c
                ON c.id = act.center   
        JOIN
                account_receivables ar
                ON ar.center = art.center
                AND ar.id= art.id
                AND ar.ar_type != 6               
        LEFT JOIN
                (
                SELECT
                        pr.center
                        ,pr.id
                        ,pr.subid
                        ,ar.customercenter
                        ,ar.customerid
                FROM
                        payment_requests pr
                JOIN
                        payment_agreements pag
                        ON pr.center = pag.center 
                        AND pr.id = pag.id 
                        AND pr.agr_subid = pag.subid 
                JOIN
                        account_receivables ar 
                        ON ar.center = pag.center 
                        AND ar.id = pag.id
                )pr                      
                ON pr.center = art.payreq_spec_center
                AND pr.id = art.payreq_spec_id
                AND pr.subid = art.payreq_spec_subid                        
        JOIN
                params
                ON params.center_id = act.center       
        WHERE
                act.center IN (:Scope)
                AND
                act.trans_time BETWEEN params.FromDate AND params.ToDate
        )t
WHERE
    t."Cost Center" NOT IN ('02.00.1200-Bank account: EFT', '02.00.1212.1-Account Receivables: EFT account (persons)', '02.00.1280.4-Cash register interim', '02.00.1281-Account Receivables: Cash account', '02.00.1282.1-Account Receivables: External debt account', '02.00.1283-Account Receivables: Installment plan account', '02.00.1200.1-Bank account: credit card', '02.00.1240.1-Inventory Adjustment')
GROUP BY
        t."Cost Center"
        ,t."Club ID"
        ,t."Club Name"
                                         

                      