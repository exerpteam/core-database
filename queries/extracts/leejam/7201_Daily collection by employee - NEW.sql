-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1."Centre id"
        ,t1."Centre name"
        ,t1."Employee ID"
        ,t1."Employee Name"        
        ,t1."Date"
        ,SUM(t1."Cash")                         AS "Cash"
        ,SUM(t1."Credit Card")                  AS "Credit Card"
        ,SUM(t1."Cash account")                 AS "Cash account"
        ,SUM(t1."Other")                        AS "Other"
        ,SUM(t1."No of Manual Transactions")    AS "Manual transactions" 
FROM
        (
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
        --Cash and Credit Card Transactions
        SELECT DISTINCT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.crttype
                ,crt.employeecenter||'emp'||crt.employeeid AS "Employee ID"
                ,empp.fullname AS "Employee Name"
                ,CASE
                        WHEN crt.crttype = 1 THEN crt.amount 
                        ELSE 0
                END AS "Cash"
                ,CASE
                        WHEN crt.crttype IN (6,7,8) THEN crt.amount 
                        ELSE 0
                END AS "Credit Card"
                ,0 AS "Cash account"
                ,0 AS "Other"
                ,CASE
                        WHEN cr.name = 'ManualCashregister' THEN 1 
                        ELSE 0
                END AS "No of Manual Transactions" 
                ,inv.center
                ,inv.id
                ,CASE
                        WHEN cnl.center IS NOT NULL THEN 'Yes'
                        ELSE 'No'
                END AS returned              
        FROM
                cashregistertransactions crt
        JOIN
                centers c
                ON c.id = crt.center
        JOIN
                employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
        JOIN
                persons empp
                ON empp.center = emp.personcenter
                AND empp.id = emp.personid                
        JOIN 
                params 
                ON params.CENTER_ID = c.id 
        JOIN
                leejam.cashregisters cr
                ON cr.center = crt.center
                AND cr.id = crt.id
        LEFT JOIN
                invoices inv
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id
        LEFT JOIN
                invoice_lines_mt invl  
                ON inv.center = invl.center
                AND inv.id = invl.id 
        LEFT JOIN
                leejam.credit_note_lines_mt cnl
                ON cnl.invoiceline_center = invl.center
                AND cnl.invoiceline_id = invl.id
                AND cnl.invoiceline_subid = invl.subid
                AND cnl.reason IN (7,14,15,37)                                                                          
        WHERE
                crt.crttype IN (1,6,7,8)
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate   
        UNION ALL
        --Cash and Credit Card refund Transactions AND Cash Account and Other Transactions
        SELECT DISTINCT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.crttype
                ,crt.employeecenter||'emp'||crt.employeeid AS "Employee ID"
                ,empp.fullname AS "Employee Name"
                ,CASE
                        WHEN crt.crttype = 4 THEN -crt.amount 
                        ELSE 0
                END AS "Cash"
                ,CASE
                        WHEN crt.crttype = 18 THEN -crt.amount 
                        ELSE 0
                END AS "Credit Card"
                ,CASE
                        WHEN crt.crttype = 5 THEN crt.amount 
                        ELSE 0
                END  AS "Cash account"
                ,CASE
                        WHEN crt.crttype in (9,12,13,17,22) THEN crt.amount 
                        ELSE 0
                END  AS "Other"  
                ,CASE
                        WHEN cr.name = 'ManualCashregister' THEN 1 
                        ELSE 0
                END AS "No of Manual Transactions"
                ,crt.center
                ,crt.id
                ,CASE
                        WHEN cnl.center IS NOT NULL THEN 'Yes'
                        ELSE 'No'
                END AS returned                                  
        FROM
                cashregistertransactions crt
        JOIN
                centers c
                ON c.id = crt.center
        JOIN
                employees emp
                ON emp.center = crt.employeecenter
                AND emp.id = crt.employeeid
        JOIN
                persons empp
                ON empp.center = emp.personcenter
                AND empp.id = emp.personid                                
        JOIN 
                params 
                ON params.CENTER_ID = c.id
        JOIN
                leejam.cashregisters cr
                ON cr.center = crt.center
                AND cr.id = crt.id  
        LEFT JOIN
                invoices inv
                ON inv.paysessionid = crt.paysessionid
                AND inv.cashregister_center = crt.center
                AND inv.cashregister_id = crt.id
        LEFT JOIN
                invoice_lines_mt invl  
                ON inv.center = invl.center
                AND inv.id = invl.id 
        LEFT JOIN
                leejam.credit_note_lines_mt cnl
                ON cnl.invoiceline_center = invl.center
                AND cnl.invoiceline_id = invl.id
                AND cnl.invoiceline_subid = invl.subid
                AND cnl.reason IN (7,14,15,37)                                                                                                  
        WHERE
                crt.crttype IN (4,18,5,9,12,13,17,22)
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate                                                        
        )t1
WHERE
        returned = 'No'        
GROUP BY
        t1."Centre id"
        ,t1."Centre name"
        ,t1."Date"  
        ,t1."Employee ID"
        ,t1."Employee Name"                                 
