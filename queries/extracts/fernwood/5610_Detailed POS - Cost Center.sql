-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
                                        longtodateC(crt.transtime,crt.center) AS "TransactionDate"
                                        ,Case crt.crttype
                                                WHEN 1 THEN 'CASH'
                                                WHEN 2 THEN 'CHANGE'
                                                WHEN 3 THEN 'RETURN ON CREDIT'
                                                WHEN 4 THEN 'PAYOUT CASH'
                                                WHEN 5 THEN 'PAID BY CASH AR ACCOUNT'
                                                WHEN 6 THEN 'DEBIT CARD'
                                                WHEN 7 THEN 'CREDIT CARD'
                                                WHEN 8 THEN 'DEBIT OR CREDIT CARD'
                                                WHEN 9 THEN 'GIFT CARD'
                                                WHEN 10 THEN 'CASH ADJUSTMENT'
                                                WHEN 11 THEN 'CASH TRANSFER'
                                                WHEN 12 THEN 'PAYMENT AR'
                                                WHEN 13 THEN 'CONFIG PAYMENT METHOD'
                                                WHEN 14 THEN 'CASH REGISTER PAYOUT'
                                                WHEN 15 THEN 'CREDIT CARD ADJUSTMENT'
                                                WHEN 16 THEN 'CLOSING CASH ADJUST'
                                                WHEN 17 THEN 'VOUCHER'
                                                WHEN 18 THEN 'PAYOUT CREDIT CARD'
                                                WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS'
                                                WHEN 20 THEN 'CLOSING CREDIT CARD ADJ'
                                                WHEN 21 THEN 'TRANSFER BACK CASH COINS'
                                                WHEN 22 THEN 'INSTALLMENT PLAN'
                                                WHEN 100 THEN 'INITIAL CASH'
                                                WHEN 101 THEN 'MANUAL'
                                                ELSE 'Undefined'
                                        END AS "Type"
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
        cashregistertransactions crt
LEFT JOIN
        invoices inv
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id         
LEFT JOIN
        invoice_lines_mt inl 
                ON inv.center = inl.center 
                AND inv.id = inl.id
LEFT JOIN 
        products pro
                ON pro.center = inl.productcenter
                AND pro.id = inl.productid
LEFT JOIN 
        product_group pg
                ON pg.id = pro.primary_product_group_id
LEFT JOIN
        product_account_configurations pac
                ON pac.id = pro.product_account_config_id  
LEFT JOIN
        accounts accincome
                ON pac.sales_account_globalid = accincome.globalid 
                AND pro.center = accincome.center                                
LEFT JOIN 
        credit_notes cn
                ON cn.paysessionid = crt.paysessionid
                AND cn.cashregister_center = crt.center
                AND cn.cashregister_id = crt.id
LEFT JOIN
        credit_note_lines_mt cnt
                ON cnt.center = cn.center
                AND cnt.id = cn.id
LEFT JOIN 
        products proc
                ON proc.center = cnt.productcenter
                AND proc.id = cnt.productid
LEFT JOIN 
        product_group pgc
                ON pgc.id = proc.primary_product_group_id   
LEFT JOIN
        product_account_configurations pacr
                ON pacr.id = proc.product_account_config_id                 
LEFT JOIN
        accounts accrefund
                ON pacr.refund_account_globalid = accrefund.globalid 
                AND proc.center = accrefund.center
LEFT JOIN
        persons p
                ON p.center = crt.customercenter
                AND p.id = crt.customerid                 
LEFT JOIN 
        employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
LEFT JOIN 
        persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid                              
WHERE 
        crt.amount != 0
        AND
        crt.center in (:Scope)
        AND
        crt.transtime BETWEEN datetolongC(TO_CHAR(to_date(:FromDate, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),crt.center) 
        AND datetolongC(TO_CHAR(to_date(:ToDate, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),crt.center) + 86400 * 1000
        AND 
        crt.crttype NOT IN (2,5,9,10,11,12,13,14,15,16,17,19,20,21,22,100,101)
        AND
        (inl.total_amount != 0 OR cnt.total_amount != 0)
UNION ALL
SELECT 
                                        longtodateC(crt.transtime,crt.center) AS "TransactionDate"
                                        ,Case crt.crttype
                                                WHEN 1 THEN 'CASH'
                                                WHEN 2 THEN 'CHANGE'
                                                WHEN 3 THEN 'RETURN ON CREDIT'
                                                WHEN 4 THEN 'PAYOUT CASH'
                                                WHEN 5 THEN 'PAID BY CASH AR ACCOUNT'
                                                WHEN 6 THEN 'DEBIT CARD'
                                                WHEN 7 THEN 'CREDIT CARD'
                                                WHEN 8 THEN 'DEBIT OR CREDIT CARD'
                                                WHEN 9 THEN 'GIFT CARD'
                                                WHEN 10 THEN 'CASH ADJUSTMENT'
                                                WHEN 11 THEN 'CASH TRANSFER'
                                                WHEN 12 THEN 'PAYMENT AR'
                                                WHEN 13 THEN 'CONFIG PAYMENT METHOD'
                                                WHEN 14 THEN 'CASH REGISTER PAYOUT'
                                                WHEN 15 THEN 'CREDIT CARD ADJUSTMENT'
                                                WHEN 16 THEN 'CLOSING CASH ADJUST'
                                                WHEN 17 THEN 'VOUCHER'
                                                WHEN 18 THEN 'PAYOUT CREDIT CARD'
                                                WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS'
                                                WHEN 20 THEN 'CLOSING CREDIT CARD ADJ'
                                                WHEN 21 THEN 'TRANSFER BACK CASH COINS'
                                                WHEN 22 THEN 'INSTALLMENT PLAN'
                                                WHEN 100 THEN 'INITIAL CASH'
                                                WHEN 101 THEN 'MANUAL'
                                                ELSE 'Undefined'
                                        END AS "Type"
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
        cashregistertransactions crt
JOIN
        crt_art_link link 
                ON crt.center = link.crt_center 
                AND crt.id = link.crt_id 
                AND crt.subid = link.crt_subid 
JOIN 
        ar_trans art 
                ON art.center = link.art_center 
                AND art.id = link.art_id 
                AND art.subid = link.art_subid 
JOIN
        art_match amatch
                ON amatch.art_paying_center = art.center
                AND amatch.art_paying_id = art.id
                AND amatch.art_paying_subid = art.subid
JOIN       
        ar_trans armatch
                ON amatch.art_paid_center = armatch.center
                AND amatch.art_paid_id = armatch.id
                AND amatch.art_paid_subid = armatch.subid         
JOIN
        invoices invp
                ON invp.center = armatch.ref_center
                AND invp.id = armatch.ref_id      
JOIN
        invoice_lines_mt inlp 
                ON invp.center = inlp.center 
                AND invp.id = inlp.id                
JOIN 
        products prop
                ON prop.center = inlp.productcenter
                AND prop.id = inlp.productid
JOIN 
        product_group pgp
                ON pgp.id = prop.primary_product_group_id 
JOIN
        product_account_configurations pacp
                ON pacp.id = prop.product_account_config_id   
JOIN
        accounts accincomep
                ON pacp.sales_account_globalid = accincomep.globalid 
                AND prop.center = accincomep.center 
LEFT JOIN
        persons p
                ON p.center = crt.customercenter
                AND p.id = crt.customerid                 
LEFT JOIN 
        employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
LEFT JOIN 
        persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid                                                                                                                                                                                                                                            
WHERE 
        crt.amount != 0
        AND
        crt.center in (:Scope)
        AND
        crt.transtime BETWEEN datetolongC(TO_CHAR(to_date(:FromDate, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),crt.center) 
        AND datetolongC(TO_CHAR(to_date(:ToDate, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),crt.center) + 86400 * 1000
        AND 
        crt.crttype NOT IN (2,5,9,10,11,12,13,14,15,16,17,19,20,21,22,100,101)
        AND
        inlp.total_amount != 0
UNION ALL
SELECT  
                                        longtodateC(crt.transtime,crt.center) AS "TransactionDate"
                                        ,Case crt.crttype
                                                WHEN 1 THEN 'CASH'
                                                WHEN 2 THEN 'CHANGE'
                                                WHEN 3 THEN 'RETURN ON CREDIT'
                                                WHEN 4 THEN 'PAYOUT CASH'
                                                WHEN 5 THEN 'PAID BY CASH AR ACCOUNT'
                                                WHEN 6 THEN 'DEBIT CARD'
                                                WHEN 7 THEN 'CREDIT CARD'
                                                WHEN 8 THEN 'DEBIT OR CREDIT CARD'
                                                WHEN 9 THEN 'GIFT CARD'
                                                WHEN 10 THEN 'CASH ADJUSTMENT'
                                                WHEN 11 THEN 'CASH TRANSFER'
                                                WHEN 12 THEN 'PAYMENT AR'
                                                WHEN 13 THEN 'CONFIG PAYMENT METHOD'
                                                WHEN 14 THEN 'CASH REGISTER PAYOUT'
                                                WHEN 15 THEN 'CREDIT CARD ADJUSTMENT'
                                                WHEN 16 THEN 'CLOSING CASH ADJUST'
                                                WHEN 17 THEN 'VOUCHER'
                                                WHEN 18 THEN 'PAYOUT CREDIT CARD'
                                                WHEN 19 THEN 'TRANSFER BETWEEN REGISTERS'
                                                WHEN 20 THEN 'CLOSING CREDIT CARD ADJ'
                                                WHEN 21 THEN 'TRANSFER BACK CASH COINS'
                                                WHEN 22 THEN 'INSTALLMENT PLAN'
                                                WHEN 100 THEN 'INITIAL CASH'
                                                WHEN 101 THEN 'MANUAL'
                                                ELSE 'Undefined'
                                        END AS "Type"
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
        cashregistertransactions crt
JOIN 
        ar_trans art 
                ON art.center = crt.artranscenter
                AND art.id = crt.artransid
                AND art.subid = crt.artranssubid 
JOIN
        art_match amatch
                ON amatch.art_paying_center = art.center
                AND amatch.art_paying_id = art.id
                AND amatch.art_paying_subid = art.subid
JOIN       
        ar_trans armatch
                ON amatch.art_paid_center = armatch.center
                AND amatch.art_paid_id = armatch.id
                AND amatch.art_paid_subid = armatch.subid         
LEFT JOIN
        invoices invp
                ON invp.center = armatch.ref_center
                AND invp.id = armatch.ref_id 
LEFT JOIN
        invoice_lines_mt inlp 
                ON invp.center = inlp.center 
                AND invp.id = inlp.id                
LEFT JOIN 
        products prop
                ON prop.center = inlp.productcenter
                AND prop.id = inlp.productid
LEFT JOIN 
        product_group pgp
                ON pgp.id = prop.primary_product_group_id 
LEFT JOIN
        product_account_configurations pacp
                ON pacp.id = prop.product_account_config_id   
LEFT JOIN
        accounts accincomep
                ON pacp.sales_account_globalid = accincomep.globalid 
                AND prop.center = accincomep.center  
LEFT JOIN
        persons p
                ON p.center = crt.customercenter
                AND p.id = crt.customerid                 
LEFT JOIN 
        employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
LEFT JOIN 
        persons pemp
                ON pemp.center = emp.personcenter
                AND pemp.id = emp.personid 
LEFT JOIN
        account_trans act
                ON  act.center = armatch.ref_center
                AND act.id = armatch.ref_id
                AND act.subid = armatch.ref_subid
LEFT JOIN 
        accounts acac
                ON acac.center = act.credit_accountcenter
                AND acac.id = act.credit_accountid                                                                                                                                                                                                                                           
WHERE 
        crt.amount != 0
        AND
        crt.center in (:Scope)
        AND
        crt.transtime BETWEEN datetolongC(TO_CHAR(to_date(:FromDate, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),crt.center) 
        AND datetolongC(TO_CHAR(to_date(:ToDate, 'YYYY-MM-dd HH24:MI'), 'YYYY-MM-dd HH24:MI'),crt.center) + 86400 * 1000
        AND 
        crt.crttype NOT IN (2,5,9,10,11,12,13,14,15,16,17,19,20,21,22,100,101)
        AND
        inlp.total_amount != 0
