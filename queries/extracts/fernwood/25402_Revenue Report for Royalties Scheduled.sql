-- The extract is extracted from Exerp on 2026-02-08
-- Donna Hudec Scheduled Report
WITH params AS (
    SELECT
        datetolongC(TO_CHAR(CAST('2025-07-01' AS DATE), 'YYYY-MM-dd HH24:MI'), c.id) AS FromDate,
        c.id AS center_id,
        CAST((datetolongC(TO_CHAR((CAST('2026-06-30' AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'), c.id) - 1) AS BIGINT) AS ToDate
    FROM centers c
)
SELECT 
        finalsum.*
        ,(finalsum."Bank Account Debits" - finalsum."Bank Account Rejections"  + finalsum."Bank Account Representations" - finalsum."Bank Account Representations Rejections" + finalsum."Bank Account Refunds" - finalsum."Bank Account Refunds Rejections"  + finalsum."Credit Card Debits" - finalsum."Credit Card Rejections" + finalsum."Credit Card Representation" - finalsum."Credit Card Representation Rejections" + finalsum."POS Payments Cash" + finalsum."POS Payments Credit Card" + finalsum."HQ Collections" + finalsum."Debt Payments" + finalsum."Online sales") AS "Income subject to Royalty and Marketing Fees Inc GST"
        ,(finalsum."Bank Account Debits" - finalsum."Bank Account Rejections"  + finalsum."Bank Account Representations" - finalsum."Bank Account Representations Rejections" + finalsum."Bank Account Refunds" - finalsum."Bank Account Refunds Rejections"  + finalsum."Credit Card Debits" - finalsum."Credit Card Rejections" + finalsum."Credit Card Representation" - finalsum."Credit Card Representation Rejections" + finalsum."POS Payments Cash" + finalsum."POS Payments Credit Card" + finalsum."HQ Collections" + finalsum."Debt Payments" + finalsum."Online sales") * 0.07 AS "Franchise Royalty Fee"        
        ,(finalsum."Bank Account Debits" - finalsum."Bank Account Rejections"  + finalsum."Bank Account Representations" - finalsum."Bank Account Representations Rejections" + finalsum."Bank Account Refunds" - finalsum."Bank Account Refunds Rejections"  + finalsum."Credit Card Debits" - finalsum."Credit Card Rejections" + finalsum."Credit Card Representation" - finalsum."Credit Card Representation Rejections" + finalsum."POS Payments Cash" + finalsum."POS Payments Credit Card" + finalsum."HQ Collections" + finalsum."Debt Payments" + finalsum."Online sales") * 0.05 AS "National Advertising Fee"      
        
FROM
        (
        SELECT 
                t."Center"
                ,sum(t."Bank Account Debits") AS "Bank Account Debits"
                ,sum(t."Bank Account Rejections") AS "Bank Account Rejections"
                ,sum(t."Bank Account Representations") AS "Bank Account Representations"
                ,sum(t."Bank Account Representations Rejections" ) AS "Bank Account Representations Rejections" 
                ,sum(t."Bank Account Refunds") AS "Bank Account Refunds"
                ,sum(t."Bank Account Refunds Rejections" ) AS "Bank Account Refunds Rejections"                                                             
                ,sum(t."Credit Card Debits") AS "Credit Card Debits"
                ,sum(t."Credit Card Rejections") AS "Credit Card Rejections"
                ,sum(t."Credit Card Representation") AS "Credit Card Representation"
                ,sum(t."Credit Card Representation Rejections") AS "Credit Card Representation Rejections"
                ,sum(t."POS Payments Cash") AS "POS Payments Cash"
                ,sum(t."POS Payments Credit Card") AS "POS Payments Credit Card"
                ,sum(t."HQ payments") AS "HQ Collections" 
                ,sum(t."Debt Payments") AS "Debt Payments"
                ,sum(t."Online sales") AS "Online sales"
        FROM
                (
                SELECT  --Direct Debit    
                                t1."Center"
                                ,t1."Bank Account Debits"
                                ,t1."Bank Account Rejections"
                                ,t1."Bank Account Representations"
                                ,t1."Bank Account Representations Rejections"  
                                ,t1."Bank Account Refunds"
                                ,t1."Bank Account Refunds Rejections"                               
                                ,t1."Credit Card Debits"
                                ,t1."Credit Card Rejections"
                                ,t1."Credit Card Representation"
                                ,t1."Credit Card Representation Rejections"
                                ,0 AS "POS Payments Cash"
                                ,0 AS "POS Payments Credit Card"
                                ,0 AS "HQ payments"
                                ,0 AS "Debt Payments"
                                ,0 AS "Online sales"
                                ,'DD' AS "Type"
                FROM
                        (
                        Select 
                                FeesonDD."Club" AS "Center"
                                ,CASE
                                        WHEN FeesonDD."Bank Account Debits" IS NULL THEN 0
                                        ELSE FeesonDD."Bank Account Debits"
                                END AS "Bank Account Debits"               
                                ,CASE
                                        WHEN FeesonDD."Bank Account Rejections" IS NULL THEN 0
                                        ELSE FeesonDD."Bank Account Rejections"
                                END AS "Bank Account Rejections"
                                ,CASE
                                        WHEN FeesonDD."Bank Account Representations" IS NULL THEN 0
                                        ELSE FeesonDD."Bank Account Representations"
                                END AS "Bank Account Representations"
                                ,CASE
                                        WHEN FeesonDD."Bank Account Representations Rejections" IS NULL THEN 0
                                        ELSE FeesonDD."Bank Account Representations Rejections"
                                END AS "Bank Account Representations Rejections"
                                ,CASE
                                        WHEN FeesonDD."Bank Account Refunds" IS NULL THEN 0
                                        ELSE FeesonDD."Bank Account Refunds"
                                END AS "Bank Account Refunds"
                                ,CASE
                                        WHEN FeesonDD."Bank Account Refunds Rejections" IS NULL THEN 0
                                        ELSE FeesonDD."Bank Account Refunds Rejections"
                                END AS "Bank Account Refunds Rejections"                                                                                
                                ,CASE
                                        WHEN FeesonDD."Credit Card Debits" IS NULL THEN 0
                                        ELSE FeesonDD."Credit Card Debits"
                                END AS "Credit Card Debits"  
                                ,CASE
                                        WHEN FeesonDD."Credit Card Rejections" IS NULL THEN 0
                                        ELSE FeesonDD."Credit Card Rejections"
                                END AS "Credit Card Rejections" 
                                ,CASE
                                        WHEN FeesonDD."Credit Card Representation" IS NULL THEN 0
                                        ELSE FeesonDD."Credit Card Representation"
                                END AS "Credit Card Representation" 
                                ,CASE
                                        WHEN FeesonDD."Credit Card Representation Rejections" IS NULL THEN 0
                                        ELSE FeesonDD."Credit Card Representation Rejections"
                                END AS "Credit Card Representation Rejections"                                                                          
                        FROM  
                                (
                                SELECT 
                                        t2."Club"
                                        ,sum(t2."Bank Account Debits") AS "Bank Account Debits"
                                        ,sum(t2."Bank Account Rejections") AS "Bank Account Rejections"
                                        ,sum(t2."Bank Account Representations") AS "Bank Account Representations"
                                        ,sum(t2."Bank Account Representations Rejections") AS "Bank Account Representations Rejections"
                                        ,sum(t2."Bank Account Refunds") AS "Bank Account Refunds"
                                        ,sum(t2."Bank Account Refunds Rejections") AS "Bank Account Refunds Rejections"                        
                                        ,sum(t2."Credit Card Debits") AS "Credit Card Debits"
                                        ,sum(t2."Credit Card Rejections") AS "Credit Card Rejections"
                                        ,sum(t2."Credit Card Representation") AS "Credit Card Representation"
                                        ,sum(t2."Credit Card Representation Rejections") AS "Credit Card Representation Rejections"
                                        ,t2."Center"
                                FROM        
                                        (
                                        SELECT 
                                                t1."Club"
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 1 AND t1."Request Type" = 'Payment' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Bank Account Debits"                
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 1 AND t1."PR State" NOT in ('Done','New','Sent','Done manually','Unknown') AND t1."Request Type" = 'Payment' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Bank Account Rejections" 
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 1 AND t1."Request Type" = 'Representation' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Bank Account Representations"                
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 1 AND t1."PR State" NOT in ('Done','New','Sent','Done manually','Unknown') AND t1."Request Type" = 'Representation' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Bank Account Representations Rejections" 
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 1 AND t1."PR State" in ('Done','New','Sent','Done manually','Unknown') AND t1."Request Type" = 'refund' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Bank Account Refunds"                
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 1 AND t1."PR State" NOT in ('Done','New','Sent','Done manually','Unknown') AND t1."Request Type" = 'refund' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Bank Account Refunds Rejections"                                                                     
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 2 AND t1."Request Type" = 'Payment' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Credit Card Debits"                
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 2 AND t1."PR State" NOT in ('Done','New','Sent','Done manually','Unknown') AND t1."Request Type" = 'Payment' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Credit Card Rejections" 
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 2 AND t1."Request Type" = 'Representation' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Credit Card Representation"                
                                                ,CASE
                                                        WHEN t1."ClearingHouseID" = 2 AND t1."PR State" NOT in ('Done','New','Sent','Done manually','Unknown') AND t1."Request Type" = 'Representation' THEN sum(t1."Amount including VAT (Exerp)")
                                                        Else 0
                                                END AS "Credit Card Representation Rejections"                                
                                                ,t1."Center"                
                                                
                                        FROM
                                                (
                                                SELECT 
                                                                p.center || 'p' || p.id AS "ExerpId"
                                                                ,p.fullname AS "Name"
                                                                ,pag.ref AS "Reference"
                                                                ,c.name as "Club"
                                                                ,pr.req_amount AS "Amount including VAT (Exerp)"
                                                                ,(CASE pr.state
                                                                        WHEN 1 THEN 'New'
                                                                        WHEN 2 THEN 'Sent'
                                                                        WHEN 3 THEN 'Done'
                                                                        WHEN 4 THEN 'Done manually'
                                                                        WHEN 5 THEN 'Failed, rejected by clearinghouse'
                                                                        WHEN 6 THEN 'Failed, bank rejected'
                                                                        WHEN 7 THEN 'Rejected, debtor'
                                                                        WHEN 8 THEN 'Cancelled'
                                                                        WHEN 12 THEN 'Failed, could not be sent'
                                                                        WHEN 17 THEN 'Failed, payment revoked'
                                                                        WHEN 19 THEN 'Failed, not supported'
                                                                        WHEN 20 THEN 'Requires approval'
                                                                        ELSE 'Unknown'
                                                                END) AS "PR State"
                                                                ,pr.clearinghouse_id AS "ClearingHouseID"
                                                                ,pr.req_date AS "Date"
                                                                ,CASE
                                                                        WHEN pr.request_type = 1 THEN 'Payment'
                                                                        WHEN pr.request_type = 6 THEN 'Representation'
                                                                        WHEN pr.request_type = 5 THEN 'refund'
                                                                END AS "Request Type"  
                                                                ,pr.center AS "Center"                                                             
                                                FROM 
                                                payment_agreements pag 
                                                JOIN account_receivables ar ON ar.center = pag.center AND ar.id = pag.id
                                                JOIN persons p ON p.center = ar.customercenter AND p.id = ar.customerid
                                                JOIN payment_requests pr ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid AND pr.state <> 8
                                                JOIN centers c ON c.id = pr.center
JOIN params ON params.center_id = pr.center
                                                WHERE                                              datetolongC(TO_CHAR(pr.req_date, 'YYYY-MM-dd HH24:MI'), pr.center) BETWEEN params.FromDate AND params.ToDate

                                                         AND 
                                                         pr.center in (:Scope)
                                                         AND
                                                         pr.request_type in (1,5,6)
                                                )t1   
                                        GROUP BY
                                                t1."Club"
                                                ,t1."ClearingHouseID"
                                                ,t1."PR State"
                                                ,t1."Request Type"
                                                ,t1."Center"
                                        )t2  
                                GROUP BY 
                                        t2."Club" 
                                        ,t2."Center"
                                )FeesonDD
                        )t1                   
                UNION ALL
                SELECT   --POS Payments Cash and Creditcard     
                                t1."ClubID" AS "Center"
                                ,0 AS "Total Bank Account Debits"
                                ,0 AS "Bank Account Rejections"
                                ,0 AS "Total Bank Account Representations"
                                ,0 AS "Bank Account Representations Rejections"  
                                ,0 AS "Total Bank Account Refunds"
                                ,0 AS "Bank Account Refunds Rejections"                               
                                ,0 AS "Total Credit Card Debits"
                                ,0 AS "Credit Card Rejections"
                                ,0 AS "Total Credit Card Representation"
                                ,0 AS "Credit Card Representation Rejections"
                                ,t1."Cash" AS "POS Payments Cash"
                                ,t1."CREDIT CARD" AS "POS Payments Credit Card"
                                ,0 AS "HQ payments"
                                ,0 AS "Debt Payments"
                                ,0 AS "Online sales"
                                ,'Frontdesk' AS "Type"           
                FROM        
                        (
                                SELECT 
                                         sum(t3."Cash") AS "Cash"
                                        ,sum(t3."CREDIT CARD") AS "CREDIT CARD"                                       
                                        ,t3."ClubID"      
                                FROM
                                        (
                                        SELECT 
                                                t2."Transaction Date"
                                                ,CASE
                                                        WHEN t2."Payment Type" in ('CASH','PAYOUT CASH') THEN coalesce(sum(t2."Sum"),0)
                                                        Else 0
                                                END AS "Cash"
                                                ,CASE
                                                        WHEN t2."Payment Type" in ('DEBIT CARD','CREDIT CARD','PAYOUT CREDIT CARD','RETURN ON CREDIT','DEBIT OR CREDIT CARD') THEN coalesce(sum(t2."Sum"),0)
                                                        Else 0
                                                END AS "CREDIT CARD" 
                                                ,t2."Club" AS "ClubID"             
                                        FROM
                                                (                
                                                SELECT 
                                                        t1."TransactionDate" AS "Transaction Date"
                                                        ,t1."Type" AS "Payment Type"
                                                        ,coalesce(sum(t1.Total),0) AS "Sum"
                                                        ,t1."Center" AS "Club"
                                                FROM
                                                        (
                                                        SELECT 
                                                                TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-DD') AS "TransactionDate"
                                                                ,longtodateC(crt.transtime,crt.center)
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
                                                                ,crt.amount AS Total
                                                                ,crt.customercenter||'p'||crt.customerid AS "Person ID"
                                                                ,crt.employeecenter||'p'||crt.employeeid AS "Employee ID"
                                                                ,crt.center
                                                                ,c.name AS "Center"                                                                         
                                                        FROM 
                                                                cashregistertransactions crt
                                                        JOIN
                                                                centers c
                                                                ON crt.center = c.id                                                
                                                        JOIN    
                                                                params 
                                                                ON params.center_id = crt.center                                                                                              
                                                        WHERE 
                                                                crt.amount != 0
                                                                AND
                                                                crt.center in (:Scope)
                                                                AND
                                                                crt.transtime BETWEEN params.FromDate AND params.ToDate
                                                                AND 
                                                                crt.crttype NOT IN (2,4,5,10,11,12,13,15,16,18,19,20,21,22,100,101)
                                                        )t1
                                                        GROUP BY
                                                        t1."TransactionDate"
                                                        ,t1."Type"
                                                        ,t1."Center"
                                                )t2     
                                        GROUP BY 
                                                t2."Transaction Date"
                                                ,t2."Payment Type" 
                                                ,t2."Club"
                                        
                                        )t3
                                GROUP BY 
                                        t3."ClubID"  
                        )t1                   
                        GROUP BY
                                t1."ClubID"             
                                ,t1."Cash"
                                ,t1."CREDIT CARD"  
                UNION ALL
                SELECT    --POS Credits Cash and Creditcard  
                                t1."ClubID" AS "Center"
                                ,0 AS "Total Bank Account Debits"
                                ,0 AS "Bank Account Rejections"
                                ,0 AS "Total Bank Account Representations"
                                ,0 AS "Bank Account Representations Rejections"  
                                ,0 AS "Total Bank Account Refunds"
                                ,0 AS "Bank Account Refunds Rejections"                               
                                ,0 AS "Total Credit Card Debits"
                                ,0 AS "Credit Card Rejections"
                                ,0 AS "Total Credit Card Representation"
                                ,0 AS "Credit Card Representation Rejections"
                                ,t1."Cash" AS "POS Payments Cash"
                                ,t1."CREDIT CARD" AS "POS Payments Credit Card"
                                ,0 AS "HQ payments"
                                ,0 AS "Debt Payments"
                                ,0 AS "COnline sales"
                                ,'Creditsfrontdesk' AS "Type"             
                FROM        
                        (
                                SELECT 
                                         -sum(t3."Cash") AS "Cash"
                                        ,-sum(t3."CREDIT CARD") AS "CREDIT CARD"                                       
                                        ,t3."ClubID"      
                                FROM
                                        (
                                        SELECT 
                                                t2."Transaction Date"
                                                ,CASE
                                                        WHEN t2."Payment Type" in ('CASH','PAYOUT CASH') THEN coalesce(sum(t2."Sum"),0)
                                                        Else 0
                                                END AS "Cash"
                                                ,CASE
                                                        WHEN t2."Payment Type" in ('DEBIT CARD','CREDIT CARD','PAYOUT CREDIT CARD','RETURN ON CREDIT','DEBIT OR CREDIT CARD') THEN coalesce(sum(t2."Sum"),0)
                                                        Else 0
                                                END AS "CREDIT CARD" 
                                                ,t2."Club" AS "ClubID"             
                                        FROM
                                                (                
                                                SELECT 
                                                        t1."TransactionDate" AS "Transaction Date"
                                                        ,t1."Type" AS "Payment Type"
                                                        ,coalesce(sum(t1.Total),0) AS "Sum"
                                                        ,t1."Center" AS "Club"
                                                FROM
                                                        (
                                                        SELECT 
                                                                TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-DD') AS "TransactionDate"
                                                                ,longtodateC(crt.transtime,crt.center)
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
                                                                ,crt.amount AS Total
                                                                ,crt.customercenter||'p'||crt.customerid AS "Person ID"
                                                                ,crt.employeecenter||'p'||crt.employeeid AS "Employee ID"
                                                                ,crt.center 
                                                                ,c.name AS "Center"                                                                         
                                                        FROM 
                                                                cashregistertransactions crt
                                                        JOIN
                                                                centers c
                                                                ON crt.center = c.id                                                
                                                        JOIN    
                                                                params 
                                                                ON params.center_id = crt.center                                                                                              
                                                        WHERE 
                                                                crt.amount != 0
                                                                AND
                                                                crt.center != 100
                                                                AND
                                                                crt.center in (:Scope)
                                                                AND
                                                                crt.transtime BETWEEN params.FromDate AND params.ToDate
                                                                AND 
                                                                crt.crttype IN (4,18)
                                                        UNION ALL
                                                        SELECT 
                                                                TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-DD') AS "TransactionDate"
                                                                ,longtodateC(crt.transtime,crt.center)
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
                                                                ,crt.amount AS Total
                                                                ,crt.customercenter||'p'||crt.customerid AS "Person ID"
                                                                ,crt.employeecenter||'p'||crt.employeeid AS "Employee ID"
                                                                ,crt.center 
                                                                ,c.name AS "Center"  
                                                        FROM 
                                                                cashregistertransactions crt
                                                        JOIN
                                                                centers c
                                                                ON crt.customercenter = c.id                                                
                                                        JOIN    
                                                                params 
                                                                ON params.center_id = crt.center                                                                                              
                                                        WHERE 
                                                                crt.amount != 0
                                                                AND
                                                                crt.center = 100
                                                                AND
                                                                crt.customercenter IN (:Scope)
                                                                AND
                                                                crt.transtime BETWEEN params.FromDate AND params.ToDate    
                                                        )t1
                                                        GROUP BY
                                                        t1."TransactionDate"
                                                        ,t1."Type"
                                                        ,t1."Center"
                                                )t2     
                                        GROUP BY 
                                                t2."Transaction Date"
                                                ,t2."Payment Type" 
                                                ,t2."Club"
                                        
                                        )t3
                                GROUP BY 
                                        t3."ClubID"  
                        )t1                   
                        GROUP BY
                                t1."ClubID"             
                                ,t1."Cash"
                                ,t1."CREDIT CARD"  
                UNION ALL
                SELECT    --HQ Payment  
                                t1."ClubID" AS "Center"
                                ,0 AS "Total Bank Account Debits"
                                ,0 AS "Bank Account Rejections"
                                ,0 AS "Total Bank Account Representations"
                                ,0 AS "Bank Account Representations Rejections"  
                                ,0 AS "Total Bank Account Refunds"
                                ,0 AS "Bank Account Refunds Rejections"                               
                                ,0 AS "Total Credit Card Debits"
                                ,0 AS "Credit Card Rejections"
                                ,0 AS "Total Credit Card Representation"
                                ,0 AS "Credit Card Representation Rejections"
                                ,0 AS "POS Payments Cash"
                                ,0 AS "POS Payments Credit Card"
                                ,t1."HQ payments"  AS "HQ payments"
                                ,0 AS "Debt Payments"
                                ,0 AS "Online sales"
                                ,'Creditsfrontdesk' AS "Type"             
                FROM        
                        (
                                SELECT 
                                         t3."Sum" AS "HQ payments"                                       
                                        ,t3."ClubID"      
                                FROM
                                        (               
                                                SELECT 
                                                        t1."TransactionDate" AS "Transaction Date"
                                                        ,t1."Type" AS "Payment Type"
                                                        ,coalesce(sum(t1.Total),0) AS "Sum"
                                                        ,t1."Center" AS "ClubID"
                                                FROM
                                                        (
                                                        SELECT 
                                                                TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-DD') AS "TransactionDate"
                                                                ,longtodateC(crt.transtime,crt.center)
                                                                ,'CONFIG PAYMENT METHOD' AS "Type"
                                                                ,crt.amount AS Total
                                                                ,crt.customercenter||'p'||crt.customerid AS "Person ID"
                                                                ,crt.employeecenter||'p'||crt.employeeid AS "Employee ID"
                                                                ,crt.center
                                                                ,c.name AS "Center"                                                                         
                                                        FROM 
                                                                cashregistertransactions crt
                                                        JOIN
                                                                centers c
                                                                ON crt.customercenter = c.id                                                
                                                        JOIN    
                                                                params 
                                                                ON params.center_id = crt.center                                                                                              
                                                        WHERE 
                                                                crt.amount != 0
                                                                AND
                                                                crt.center in (100)
                                                                AND
                                                                crt.customercenter in (:Scope)
                                                                AND
                                                                crt.transtime BETWEEN params.FromDate AND params.ToDate
                                                                AND 
                                                                crt.crttype = 13
                                                        )t1
                                                        GROUP BY
                                                        t1."TransactionDate"
                                                        ,t1."Type"
                                                        ,t1."Center"
                                        
                                        )t3
                        )t1 
                UNION ALL
                SELECT    --Debt Payment  
                                t1."ClubID" AS "Center"
                                ,0 AS "Total Bank Account Debits"
                                ,0 AS "Bank Account Rejections"
                                ,0 AS "Total Bank Account Representations"
                                ,0 AS "Bank Account Representations Rejections"  
                                ,0 AS "Total Bank Account Refunds"
                                ,0 AS "Bank Account Refunds Rejections"                               
                                ,0 AS "Total Credit Card Debits"
                                ,0 AS "Credit Card Rejections"
                                ,0 AS "Total Credit Card Representation"
                                ,0 AS "Credit Card Representation Rejections"
                                ,0 AS "POS Payments Cash"
                                ,0 AS "POS Payments Credit Card"
                                ,0 AS "HQ payments"
                                ,t1."Debt Payments" AS "Debt Payments"
                                ,0 AS "Online sales"
                                ,'Creditsfrontdesk' AS "Type"             
                FROM        
                        (
                                SELECT 
                                         t3."Sum" AS "Debt Payments"                                       
                                        ,t3."ClubID"      
                                FROM
                                        (               
                                                SELECT 
                                                        t1."TransactionDate" AS "Transaction Date"
                                                        ,t1."Type" AS "Payment Type"
                                                        ,coalesce(sum(t1.Total),0) AS "Sum"
                                                        ,t1."Center" AS "ClubID"
                                                FROM
                                                        (
                                                        SELECT
                                                                TO_CHAR(longtodateC(art.trans_time,art.center),'YYYY-MM-DD') AS "TransactionDate"
                                                                ,longtodateC(art.trans_time,art.center)
                                                                ,'External Debt Collection' AS "Type"
                                                                ,art.amount AS Total
                                                                ,ar.customercenter||'p'||ar.customerid AS "Person ID"
                                                                ,art.employeecenter||'p'||art.employeeid AS "Employee ID"
                                                                ,art.center
                                                                ,c.name AS "Center"   
                                                        FROM
                                                                ar_trans art
                                                        JOIN
                                                                account_trans act
                                                                ON act.center = art.ref_center
                                                                AND act.id = art.ref_id
                                                                AND act.subid = art.ref_subid
                                                                AND art.ref_type = 'ACCOUNT_TRANS'
                                                        JOIN
                                                                account_receivables ar
                                                                ON ar.center = art.center
                                                                AND ar.id = art.id 
                                                        JOIN
                                                                centers c
                                                                ON c.id = art.center
                                                        JOIN    
                                                                params 
                                                                ON params.center_id = art.center                         
                                                        WHERE 
                                                                act.info_type = 4
                                                                AND
                                                                ar.ar_type = 5
                                                                AND
                                                                art.trans_time BETWEEN params.FromDate AND params.ToDate
                                                                AND
                                                                ar.customercenter in (:Scope)
                                                        )t1
                                                        GROUP BY
                                                        t1."TransactionDate"
                                                        ,t1."Type"
                                                        ,t1."Center"
                                        
                                        )t3
                        )t1
                UNION ALL
                SELECT    --Card refunds 
                                t1."ClubID" AS "Center"
                                ,0 AS "Total Bank Account Debits"
                                ,0 AS "Bank Account Rejections"
                                ,0 AS "Total Bank Account Representations"
                                ,0 AS "Bank Account Representations Rejections"  
                                ,0 AS "Total Bank Account Refunds"
                                ,0 AS "Bank Account Refunds Rejections"                               
                                ,0 AS "Total Credit Card Debits"
                                ,0 AS "Credit Card Rejections"
                                ,0 AS "Total Credit Card Representation"
                                ,0 AS "Credit Card Representation Rejections"
                                ,0 AS "POS Payments Cash"
                                ,0 AS "POS Payments Credit Card"
                                ,0 AS "HQ payments"
                                ,0 AS "Debt Payments"
                                ,t1."Online sales" AS "Online sales"
                                ,'Online sales' AS "Type"             
                FROM        
                        (
                                SELECT 
                                         t3."Sum" AS "Online sales"                                       
                                        ,t3."ClubID"      
                                FROM
                                        (               
                                                SELECT 
                                                        t1."TransactionDate" AS "Transaction Date"
                                                        ,t1."Type" AS "Payment Type"
                                                        ,coalesce(sum(t1.Total),0) AS "Sum"
                                                        ,t1."Center" AS "ClubID"
                                                FROM
                                                        (
                                                         SELECT
                                                                art.amount AS Total
                                                                ,longtodateC(art.trans_time,art.center) AS "TransactionDate" 
                                                                ,act.center  
                                                                ,'Online sales' AS "Type" 
                                                                ,c.name AS "Center"  
                                                        FROM
                                                                account_trans act
                                                        JOIN
                                                                ar_trans art
                                                                ON act.center = art.ref_center
                                                                AND act.id = art.ref_id
                                                                AND act.subid = art.ref_subid
                                                                AND art.ref_type = 'ACCOUNT_TRANS'
                                                        JOIN
                                                                account_receivables ar
                                                                ON ar.center = art.center
                                                                AND ar.id = art.id 
                                                        JOIN
                                                                centers c
                                                                ON c.id = art.center
                                                        JOIN    
                                                                params 
                                                                ON params.center_id = art.center                         
                                                        WHERE 
                                                                act.info_type = 8
                                                                AND
                                                                ar.ar_type = 4
                                                                AND
                                                                act.trans_time BETWEEN params.FromDate AND params.ToDate
                                                                AND
                                                                ar.customercenter in (:Scope)    
                                                        )t1
                                                        GROUP BY
                                                        t1."TransactionDate"
                                                        ,t1."Type"
                                                        ,t1."Center"
                                        
                                        )t3
                        )t1                                                
                )t 
        GROUP BY
                t."Center"    
        )finalsum   
                                                                                  