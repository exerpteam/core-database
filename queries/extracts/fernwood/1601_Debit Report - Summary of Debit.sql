SELECT
                t2."Club"
                ,t2."Date"
                ,sum(t2."BAAmount")+sum(t2."BAAmountReject") AS "Bank Account Total Amount Payment Requests"
                ,sum(t2."BATotal")+sum(t2."BATotalReject") AS "Bank Account Total Count Payment Requests"          
                ,sum(t2."BAAmountReject") AS "Bank Account Total Amount Rejects"
                ,sum(t2."BATotalReject") AS "Bank Account Total Count Rejects"
                ,sum(t2."CCAmount")+sum(t2."CCAmountReject") AS "Credit Card Total Amount Payment Requests"
                ,sum(t2."CCTotal")+sum(t2."CCTotalReject") AS "Credit Card Total Count Payment Requests"          
                ,sum(t2."CCAmountReject") AS "Credit Card Total Amount Rejects"
                ,sum(t2."CCTotalReject") AS "Credit Card Total Count  Rejects"
                ,sum(t2."AMEXAmount")+sum(t2."AMEXAmountReject") AS "AMEX Total Amount Payment Requests"
                ,sum(t2."AMEXTotal")+sum(t2."AMEXTotalReject") AS "AMEX Total Count Payment Requests"          
                ,sum(t2."AMEXAmountReject") AS "AMEX Total Amount Rejects"
                ,sum(t2."AMEXTotalReject") AS "AMEX Total Count  Rejects"                
                ,sum(t2."DINERSAmount")+sum(t2."DINERSAmountReject") AS "DINERS Total Amount Payment Requests"
                ,sum(t2."DINERSTotal")+sum(t2."DINERSTotalReject") AS "DINERS Total Count Payment Requests"          
                ,sum(t2."DINERSAmountReject") AS "DINERS Total Amount Rejects"
                ,sum(t2."DINERSTotalReject") AS "DINERS Total Count  Rejects"                
FROM
                (     
                SELECT
                        t1."Club"
                        ,t1."Date"
                        ,CASE
                                WHEN t1."ClearingHouseID" = 1 AND t1."PR State" in ('Done','New','Sent') AND "Credit Card" = 'Other'THEN sum(t1."Amount including VAT (Exerp)")
                                Else 0
                        END AS "BAAmount" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 1 AND t1."PR State" in ('Done','New','Sent') AND "Credit Card" = 'Other' THEN count(*)
                                Else 0
                        END AS "BATotal"
                        ,CASE
                                WHEN t1."ClearingHouseID" = 1 AND t1."PR State" not in ('Done','New','Sent') AND "Credit Card" = 'Other' THEN sum(t1."Amount including VAT (Exerp)")
                                Else 0
                        END AS "BAAmountReject" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 1 AND t1."PR State" not in ('Done','New','Sent') AND "Credit Card" = 'Other' THEN count(*)
                                Else 0
                        END AS "BATotalReject"
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" in ('Done','New','Sent') THEN sum(t1."Amount including VAT (Exerp)")
                                Else 0
                        END AS "CCAmount" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" in ('Done','New','Sent') THEN count(*)
                                Else 0
                        END AS "CCTotal"
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" not in ('Done','New','Sent') THEN sum(t1."Amount including VAT (Exerp)")
                                Else 0
                        END AS "CCAmountReject" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" not in ('Done','New','Sent') THEN count(*)
                                Else 0
                        END AS "CCTotalReject" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" in ('Done','New','Sent') AND "Credit Card" = 'AMEX' THEN sum(t1."Amount including VAT (Exerp)")
                                Else 0
                        END AS "AMEXAmount" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" in ('Done','New','Sent') AND "Credit Card" = 'AMEX' THEN count(*)
                                Else 0
                        END AS "AMEXTotal"
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" not in ('Done','New','Sent') AND "Credit Card" = 'AMEX' THEN sum(t1."Amount including VAT (Exerp)")
                                Else 0
                        END AS "AMEXAmountReject" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" not in ('Done','New','Sent') AND "Credit Card" = 'AMEX' THEN count(*)
                                Else 0
                        END AS "AMEXTotalReject"   
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" in ('Done','New','Sent') AND "Credit Card" = 'DINERS' THEN sum(t1."Amount including VAT (Exerp)")
                                Else 0
                        END AS "DINERSAmount" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" in ('Done','New','Sent') AND "Credit Card" = 'DINERS' THEN count(*)
                                Else 0
                        END AS "DINERSTotal"
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" not in ('Done','New','Sent') AND "Credit Card" = 'DINERS' THEN sum(t1."Amount including VAT (Exerp)")
                                Else 0
                        END AS "DINERSAmountReject" 
                        ,CASE
                                WHEN t1."ClearingHouseID" = 2 AND t1."PR State" not in ('Done','New','Sent') AND "Credit Card" = 'DINERS' THEN count(*)
                                Else 0
                        END AS "DINERSTotalReject"                                                                       
                FROM
                        (
                        SELECT 
                        p.center || 'p' || p.id AS "ExerpId", 
                        p.fullname AS "Name", 
                        pag.ref AS "Reference",
                        c.name as "Club",        
                        pr.req_amount AS "Amount including VAT (Exerp)",
                        (CASE pr.state
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
                        END) AS "PR State",
                        pr.clearinghouse_id AS "ClearingHouseID",
                        pr.req_date AS "Date"
                        ,CASE
                                WHEN pag.clearinghouse = 2 AND pag.bank_accno like '37%' THEN 'AMEX'
                                WHEN pag.clearinghouse = 2 AND pag.bank_accno like '34%' THEN 'AMEX'
                                WHEN pag.clearinghouse = 2 AND pag.bank_accno like '36%' THEN 'DINERS'
                                WHEN pag.clearinghouse = 2 AND pag.bank_accno like '38%' THEN 'DINERS'
                                ELSE 'Other'
                        END AS "Credit Card"  
                        FROM 
                                payment_agreements pag 
                        JOIN account_receivables ar ON ar.center = pag.center AND ar.id = pag.id
                        JOIN persons p ON p.center = ar.customercenter AND p.id = ar.customerid
                        JOIN payment_requests pr ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid
                        JOIN centers c ON c.id = pr.center
                        WHERE 
                                        pr.due_date between :FromDate and :ToDate
                                        AND pr.center in (:Scope)
                                        AND pr.request_type =1          
                        )t1
GROUP BY
        t1."Club"
        ,t1."Date"
        ,t1."ClearingHouseID"
        ,t1."PR State"
        ,t1."Credit Card"
        )t2
GROUP BY 
        t2."Club"
        ,t2."Date"        
                        