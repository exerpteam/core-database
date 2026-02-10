-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:FromDate AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:ToDate AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT 
        *
FROM
                (
                SELECT 
                                p.center || 'p' || p.id AS "ExerpId"
                                ,pag.ref AS "Reference"
                                ,c.name as "Club"
                                ,pr.req_amount AS "Amount"
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
                                ,'DD' AS "Type"                                                            
                FROM 
                        payment_agreements pag 
                JOIN 
                        account_receivables ar 
                        ON ar.center = pag.center 
                        AND ar.id = pag.id
                JOIN 
                        persons p 
                        ON p.center = ar.customercenter 
                        AND p.id = ar.customerid
                JOIN 
                        payment_requests pr 
                        ON pr.center = pag.center 
                        AND pr.id = pag.id 
                        AND pr.agr_subid = pag.subid 
                        AND pr.state <> 8
                JOIN 
                        centers c 
                        ON c.id = pr.center
                WHERE 
                         pr.req_date BETWEEN :FromDate and :ToDate
                         AND 
                         pr.center in (:Scope)
                         AND
                         pr.request_type in (1,5,6)
                UNION ALL
                SELECT 
                        crt.customercenter||'p'||crt.customerid AS ExerpId
                        ,crt.coment AS Reference
                        ,c.name AS Club  
                        ,crt.amount AS "Amount"
                        ,NULL AS "PR State"
                        ,NULL AS ClearingHouseID
                        ,longtodateC(crt.transtime,crt.center) AS "Date"
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
                        END AS "Request Type"
                        ,crt.center AS Center
                        ,'Frontdesk' AS "Type"                                                                                                                        
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
                UNION ALL
                SELECT 
                        crt.customercenter||'p'||crt.customerid AS ExerpId
                        ,crt.coment AS Reference
                        ,c.name AS Club
                        ,-crt.amount AS "Amount"
                        ,NULL AS "PR State"
                        ,NULL AS "ClearingHouseID"
                        ,longtodateC(crt.transtime,crt.center) AS "Date"
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
                        END AS "Request Type"
                        ,crt.center AS Center                                                 
                        ,'Payouts Credits Cash and Creditcard' AS "Type"                                                                          
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
                        crt.customercenter||'p'||crt.customerid AS ExerpId
                        ,crt.coment AS Reference
                        ,c.name AS Club
                        ,-crt.amount AS "Amount"
                        ,NULL AS "PR State"
                        ,NULL AS "ClearingHouseID"
                        ,longtodateC(crt.transtime,crt.center) AS "Date"
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
                        END AS "Request Type"
                        ,crt.customercenter AS Center                                                 
                        ,'Payouts Credits Cash and Creditcard' AS "Type" 
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
                        crt.center = 100
                        AND
                        crt.customercenter IN (:Scope)
                        AND
                        crt.transtime BETWEEN params.FromDate AND params.ToDate
                        AND
                        crt.crttype NOT IN (12,13,22)
                UNION ALL
                SELECT 
                        crt.customercenter||'p'||crt.customerid AS ExerpId
                        ,crt.coment AS Reference
                        ,c.name AS Club
                        ,crt.amount AS Amount
                        ,NULL AS "PR State"
                        ,NULL AS ClearingHouseID
                        ,longtodateC(crt.transtime,crt.center) AS "Date"
                        ,'CONFIG PAYMENT METHOD' AS "Request Type"
                        ,crt.center AS Center                                              
                        ,'HQ Payment' AS "Type"                                                                        
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
                UNION ALL
                SELECT
                        ar.customercenter||'p'||ar.customerid AS ExerpId
                        ,art.info AS Reference
                        ,c.name AS "Club"  
                        ,art.amount AS Amount
                        ,NULL AS "PR State"
                        ,NULL AS "ClearingHouseID"
                        ,longtodateC(art.trans_time,art.center) AS "Date"
                        ,'External Debt Collection' AS "Request Type"
                        ,art.center AS Center                                                
                        ,'Debt Payment' AS "Type"
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
                UNION ALL
                SELECT
                        ar.customercenter||'p'||ar.customerid AS ExerpId
                        ,art.info AS Reference
                        ,c.name AS "Club"  
                        ,art.amount AS Amount
                        ,NULL AS "PR State"
                        ,NULL AS "ClearingHouseID"
                        ,longtodateC(art.trans_time,art.center) AS "Date"
                        ,'API Sales' AS "Request Type"
                        ,art.center AS Center                                                
                        ,'Online sales' AS "Type"
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
                        act.info_type IN (8,23)
                        AND
                        ar.ar_type = 4
                        AND
                        act.trans_time BETWEEN params.FromDate AND params.ToDate
                        AND
                        ar.customercenter in (:Scope)    
        )t
WHERE
        t."Type" in (:type)                                      
                                                                                            