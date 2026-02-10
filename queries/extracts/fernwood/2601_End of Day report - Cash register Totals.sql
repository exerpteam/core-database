-- The extract is extracted from Exerp on 2026-02-08
--  
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
                                t1."TransactionDate" AS "Transaction Date"
                                ,t1."Type" AS "Payment Type"
                                ,sum(t1.Total) AS "Sum"
                                ,t1."Center"
FROM
                                (
                                SELECT distinct
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
                                        ,c.name AS "Center"                                                                          
                                FROM 
                                        cashregistertransactions crt
                                JOIN 
                                        centers c
                                        ON c.id = crt.center        
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
                                        crt.crttype NOT IN (2,4,5,10,11,12,13,15,16,18,19,20,21,100,101)
)t1
GROUP BY
        t1."TransactionDate"
        ,t1."Type"
        ,t1."Center"  
                                                                       
