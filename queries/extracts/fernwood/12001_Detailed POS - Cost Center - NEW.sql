WITH
          params AS
          (
              SELECT
                  /*+ materialize */
                  datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
                  c.id AS CENTER_ID,
                  CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
              FROM
                  centers c
         ) 
SELECT 
                                        longtodateC(crt.transtime,crt.center) AS "TransactionDate"
                                        ,'Cash Register Transaction' AS "Type"
                                        ,CASE
                                                WHEN inl.total_amount is not null AND inl.total_amount != 0 AND inl.total_amount < crt.amount THEN inl.total_amount
                                                WHEN inl.total_amount is not null AND inl.total_amount != 0 AND inl.total_amount = crt.amount THEN inl.total_amount
                                                WHEN inl.total_amount is not null AND inl.total_amount != 0 AND inl.total_amount > crt.amount THEN crt.amount
                                                WHEN inl.total_amount is null AND cnt.total_amount != 0 AND cnt.total_amount < crt.amount THEN -cnt.total_amount
                                                WHEN inl.total_amount is null AND cnt.total_amount != 0 AND cnt.total_amount = crt.amount THEN -cnt.total_amount
                                                WHEN inl.total_amount is null AND cnt.total_amount != 0 AND cnt.total_amount > crt.amount THEN -crt.amount
                                                ELSE 0
                                        END AS "Amount"
                                        ,crt.amount AS "Transaction Total Amount"
                                        ,CASE
                                                WHEN inl.total_amount != 0 THEN accincome.external_id || '-' || accincome.name
                                                WHEN cnt.total_amount != 0 THEN accrefund.external_id || '-' || accrefund.name
                                        END AS "Cost Center"
                                        ,crt.customercenter||'p'||crt.customerid AS "Person ID"
                                        ,p.fullname AS "Member Name"
                                        ,crt.employeecenter||'p'||crt.employeeid AS "Employee ID"
                                        ,pemp.fullname AS "Employee Name"
                                        ,CASE
                                                WHEN pg.name is not null then pg.name
                                                ELSE pgc.name
                                        END AS "Product Group"  
                                        ,CASE
                                                WHEN pro.name is not null then pro.name
                                                ELSE proc.name
                                        END AS product
                                        ,crt.center AS "Center"                                                    
FROM 
        fernwood.cashregistertransactions crt
LEFT JOIN
        fernwood.invoices inv
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id         
LEFT JOIN
        fernwood.invoice_lines_mt inl 
                ON inv.center = inl.center 
                AND inv.id = inl.id
LEFT JOIN 
        fernwood.products pro
                ON pro.center = inl.productcenter
                AND pro.id = inl.productid
LEFT JOIN 
        fernwood.product_group pg
                ON pg.id = pro.primary_product_group_id
LEFT JOIN
        fernwood.product_account_configurations pac
                ON pac.id = pro.product_account_config_id  
LEFT JOIN
        fernwood.accounts accincome
                ON pac.sales_account_globalid = accincome.globalid 
                AND pro.center = accincome.center                                
LEFT JOIN 
        fernwood.credit_notes cn
                ON cn.paysessionid = crt.paysessionid
                AND cn.cashregister_center = crt.center
                AND cn.cashregister_id = crt.id
LEFT JOIN
        fernwood.credit_note_lines_mt cnt
                ON cnt.center = cn.center
                AND cnt.id = cn.id
LEFT JOIN 
        fernwood.products proc
                ON proc.center = cnt.productcenter
                AND proc.id = cnt.productid
LEFT JOIN 
        fernwood.product_group pgc
                ON pgc.id = proc.primary_product_group_id   
LEFT JOIN
        fernwood.product_account_configurations pacr
                ON pacr.id = proc.product_account_config_id                 
LEFT JOIN
        fernwood.accounts accrefund
                ON pacr.refund_account_globalid = accrefund.globalid 
                AND proc.center = accrefund.center
LEFT JOIN
        fernwood.persons p
                ON p.center = crt.customercenter
                AND p.id = crt.customerid                 
LEFT JOIN 
        fernwood.employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
LEFT JOIN 
        fernwood.persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid
JOIN 
        params 
                ON params.CENTER_ID = crt.center                                               
WHERE 
        crt.amount != 0
        AND
        crt.center in (:Scope)
        AND
        crt.transtime BETWEEN params.FromDate AND params.ToDate 
        AND 
        crt.crttype NOT IN (2,5,9,10,11,12,13,14,15,16,17,19,20,21,22,100,101)
        AND
        (inl.total_amount != 0 OR cnt.total_amount != 0)
UNION ALL
SELECT 
                                        longtodateC(crt.transtime,crt.center) AS "TransactionDate"
                                        ,'Installment Plan payment' AS "Type"
                                        ,CASE
                                                WHEN amatch.amount != 0 THEN amatch.amount
                                                ELSE 0
                                        END AS "Settled Amount"                                        
                                        ,crt.amount AS "Transaction Total Amount"
                                        ,CASE
                                                WHEN inlp.total_amount != 0 THEN accincomep.external_id || '-' || accincomep.name
                                        END AS "Cost Center"
                                        ,crt.customercenter||'p'||crt.customerid AS "Person ID"
                                        ,p.fullname AS "Member Name"
                                        ,crt.employeecenter||'p'||crt.employeeid AS "Employee ID"
                                        ,pemp.fullname AS "Employee Name"
                                        ,pgp.name AS "Product Group"  
                                        ,prop.name AS product
                                        ,crt.center AS "Center"                                                      
FROM 
        fernwood.cashregistertransactions crt
JOIN
        fernwood.crt_art_link link 
                ON crt.center = link.crt_center 
                AND crt.id = link.crt_id 
                AND crt.subid = link.crt_subid 
JOIN 
        fernwood.ar_trans art 
                ON art.center = link.art_center 
                AND art.id = link.art_id 
                AND art.subid = link.art_subid 
JOIN
        fernwood.art_match amatch
                ON amatch.art_paying_center = art.center
                AND amatch.art_paying_id = art.id
                AND amatch.art_paying_subid = art.subid
JOIN       
        fernwood.ar_trans armatch
                ON amatch.art_paid_center = armatch.center
                AND amatch.art_paid_id = armatch.id
                AND amatch.art_paid_subid = armatch.subid         
JOIN
        fernwood.invoices invp
                ON invp.center = armatch.ref_center
                AND invp.id = armatch.ref_id      
JOIN
        fernwood.invoice_lines_mt inlp 
                ON invp.center = inlp.center 
                AND invp.id = inlp.id                
JOIN 
        fernwood.products prop
                ON prop.center = inlp.productcenter
                AND prop.id = inlp.productid
JOIN 
        fernwood.product_group pgp
                ON pgp.id = prop.primary_product_group_id 
JOIN
        fernwood.product_account_configurations pacp
                ON pacp.id = prop.product_account_config_id   
JOIN
        fernwood.accounts accincomep
                ON pacp.sales_account_globalid = accincomep.globalid 
                AND prop.center = accincomep.center 
LEFT JOIN
        fernwood.persons p
                ON p.center = crt.customercenter
                AND p.id = crt.customerid                 
LEFT JOIN 
        fernwood.employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
LEFT JOIN 
        fernwood.persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid     
JOIN 
        params 
                ON params.CENTER_ID = crt.center                                                                                                                                                                                                                                                        
WHERE 
        crt.amount != 0
        AND
        crt.center in (:Scope)
        AND
        crt.transtime BETWEEN params.FromDate AND params.ToDate 
        AND 
        crt.crttype NOT IN (2,5,9,10,11,12,13,14,15,16,17,19,20,21,22,100,101)
        AND
        inlp.total_amount != 0
UNION ALL
SELECT  
                                        longtodateC(crt.transtime,crt.center) AS "TransactionDate"
                                        ,'Cash Register Transaction' AS "Type"
                                        ,CASE
                                                WHEN amatch.amount != 0 THEN amatch.amount
                                                ELSE 0
                                        END AS "Settled Amount"
                                        ,crt.amount AS "Transaction Total Amount"
                                        ,CASE
                                                WHEN inlp.total_amount != 0 AND armatch.ref_type = 'INVOICE' THEN accincomep.external_id || '-' || accincomep.name
                                                WHEN armatch.ref_type = 'ACCOUNT_TRANS' THEN acac.external_id || '-' || acac.name
                                        END AS "Cost Center"
                                        ,crt.customercenter||'p'||crt.customerid AS "Person ID"
                                        ,p.fullname AS "Member Name"
                                        ,crt.employeecenter||'p'||crt.employeeid AS "Employee ID"
                                        ,pemp.fullname AS "Employee Name"
                                        ,CASE
                                                WHEN armatch.ref_type = 'INVOICE' THEN pgp.name 
                                                ELSE 'N/A' 
                                        END AS "Product Group"  
                                        ,CASE
                                                WHEN armatch.ref_type = 'INVOICE' THEN prop.name
                                                WHEN armatch.ref_type = 'ACCOUNT_TRANS' THEN act.text 
                                        END AS product
                                        ,crt.center AS "Center"                                                      
FROM 
        fernwood.cashregistertransactions crt
JOIN 
        fernwood.ar_trans art 
                ON art.center = crt.artranscenter
                AND art.id = crt.artransid
                AND art.subid = crt.artranssubid 
JOIN
        fernwood.art_match amatch
                ON amatch.art_paying_center = art.center
                AND amatch.art_paying_id = art.id
                AND amatch.art_paying_subid = art.subid
JOIN       
        fernwood.ar_trans armatch
                ON amatch.art_paid_center = armatch.center
                AND amatch.art_paid_id = armatch.id
                AND amatch.art_paid_subid = armatch.subid         
LEFT JOIN
        fernwood.invoices invp
                ON invp.center = armatch.ref_center
                AND invp.id = armatch.ref_id 
LEFT JOIN
        fernwood.invoice_lines_mt inlp 
                ON invp.center = inlp.center 
                AND invp.id = inlp.id                
LEFT JOIN 
        fernwood.products prop
                ON prop.center = inlp.productcenter
                AND prop.id = inlp.productid
LEFT JOIN 
        fernwood.product_group pgp
                ON pgp.id = prop.primary_product_group_id 
LEFT JOIN
        fernwood.product_account_configurations pacp
                ON pacp.id = prop.product_account_config_id   
LEFT JOIN
        fernwood.accounts accincomep
                ON pacp.sales_account_globalid = accincomep.globalid 
                AND prop.center = accincomep.center  
LEFT JOIN
        fernwood.persons p
                ON p.center = crt.customercenter
                AND p.id = crt.customerid                 
LEFT JOIN 
        fernwood.employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
LEFT JOIN 
        fernwood.persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid 
LEFT JOIN
        fernwood.account_trans act
                ON  act.center = armatch.ref_center
                AND act.id = armatch.ref_id
                AND act.subid = armatch.ref_subid
LEFT JOIN 
        fernwood.accounts acac
                ON acac.center = act.credit_accountcenter
                AND acac.id = act.credit_accountid 
LEFT JOIN
        fernwood.invoices ninv
                ON ninv.paysessionid = crt.paysessionid
                AND ninv.cashregister_center = crt.center
                AND ninv.cashregister_id = crt.id                   
JOIN 
        params 
                ON params.CENTER_ID = crt.center                                                                                                                                                                                                                                                        
WHERE 
        crt.amount != 0
        AND
        crt.center in (:Scope)
        AND
        crt.transtime BETWEEN params.FromDate AND params.ToDate
        AND 
        crt.crttype NOT IN (2,5,9,10,11,12,13,14,15,16,17,19,20,21,22,100,101)
        AND
        inlp.total_amount != 0
        AND
        ninv.center IS NULL
UNION ALL
SELECT DISTINCT
        longtodatec(act.trans_time,act.center) AS "TransactionDate"
        ,act.info AS "Type"
        ,invl.total_amount AS "Settled Amount"
        ,act.amount AS "Transaction Total Amount"
        ,accincomep.external_id || '-' || accincomep.name AS "Cost Center"
        ,p.center||'p'||p.id AS "Person ID"
        ,p.fullname AS "Member Name"
        ,art.employeecenter||'emp'||art.employeeid AS "Employee ID"
        ,pemp.fullname AS "Employee Name"
        ,pgp.name AS "Product Group"  
        ,prop.name AS product
        ,act.center AS "Center"
FROM
        fernwood.account_trans act
JOIN
        fernwood.ar_trans art
                ON  act.center = art.ref_center
                AND act.id = art.ref_id
                AND act.subid = art.ref_subid
                AND art.ref_type = 'ACCOUNT_TRANS'
JOIN
        fernwood.art_match amatch
                ON amatch.art_paying_center = art.center
                AND amatch.art_paying_id = art.id
                AND amatch.art_paying_subid = art.subid
JOIN       
        fernwood.ar_trans armatch
                ON amatch.art_paid_center = armatch.center
                AND amatch.art_paid_id = armatch.id
                AND amatch.art_paid_subid = armatch.subid   
JOIN
        fernwood.invoices inv
                ON inv.center = armatch.ref_center
                AND inv.id = armatch.ref_id
JOIN
        fernwood.invoice_lines_mt invl 
                ON inv.center = invl.center 
                AND inv.id = invl.id 
JOIN 
        fernwood.products prop
                ON prop.center = invl.productcenter
                AND prop.id = invl.productid  
JOIN 
        fernwood.product_group pgp
                ON pgp.id = prop.primary_product_group_id 
JOIN
        fernwood.product_account_configurations pacp
                ON pacp.id = prop.product_account_config_id   
JOIN
        fernwood.accounts accincomep
                ON pacp.sales_account_globalid = accincomep.globalid 
                AND prop.center = accincomep.center  
JOIN
        fernwood.persons p
                ON p.center = inv.payer_center
                AND p.id = inv.payer_id                
JOIN 
        fernwood.employees emp
                ON emp.center = art.employeecenter
                AND emp.id = art.employeeid
JOIN 
        fernwood.persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid
JOIN 
        params 
                ON params.CENTER_ID = art.center                                                                                                            
WHERE
        act.info = 'API Sale'
        AND
        art.employeecenter||'emp'||art.employeeid IN ('100emp2202','100emp2605')
        AND 
        act.amount != 0
        AND
        invl.total_amount != 0
        AND 
        act.center IN (:Scope)
        AND
        art.trans_time BETWEEN params.FromDate AND params.ToDate