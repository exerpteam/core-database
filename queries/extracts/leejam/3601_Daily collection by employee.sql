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
        --Cash Transactions
        SELECT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.crttype
                ,crt.employeecenter||'emp'||crt.employeeid AS "Employee ID"
                ,empp.fullname AS "Employee Name"
                ,crt.amount AS "Cash"
                ,0 AS "Credit Card"
                ,0 AS "Cash account"
                ,0 AS "Other"
                ,CASE
                        WHEN cr.name = 'ManualCashregister' THEN 1 
                        ELSE 0
                END AS "No of Manual Transactions" 
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
                ON cr.center = crt.crcenter
                AND cr.id = crt.crid                                                
        WHERE
                crt.crttype = 1
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate          
        UNION ALL
        --Cash refund Transactions
        SELECT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.crttype
                ,crt.employeecenter||'emp'||crt.employeeid AS "Employee ID"  
                ,empp.fullname AS "Employee Name" 
                ,-crt.amount AS "Cash"
                ,0 AS "Credit Card"
                ,0 AS "Cash account"
                ,0 AS "Other"  
                ,CASE
                        WHEN cr.name = 'ManualCashregister' THEN 1 
                        ELSE 0
                END AS "No of Manual Transactions"                                           
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
                ON cr.center = crt.crcenter
                AND cr.id = crt.crid                                                  
        WHERE
                crt.crttype = 4
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate
        UNION ALL
        --Credit Card Transactions                
        SELECT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"

                ,crt.crttype
                ,crt.employeecenter||'emp'||crt.employeeid AS "Employee ID"
                ,empp.fullname AS "Employee Name"
                ,0 AS "Cash"                
                ,crt.amount AS "Credit Card"
                ,0 AS "Cash account"
                ,0 AS "Other"
                ,CASE
                        WHEN cr.name = 'ManualCashregister' THEN 1 
                        ELSE 0
                END AS "No of Manual Transactions"
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
                ON cr.center = crt.crcenter
                AND cr.id = crt.crid                                                
        WHERE
                crt.crttype in (6,7,8)
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate          
        UNION ALL
        --Credit Card refund Transactions
        SELECT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.crttype
                ,crt.employeecenter||'emp'||crt.employeeid AS "Employee ID"  
                ,empp.fullname AS "Employee Name" 
                ,0 AS "Cash"                
                ,-crt.amount AS "Credit Card"
                ,0 AS "Cash account"
                ,0 AS "Other"  
                ,CASE
                        WHEN cr.name = 'ManualCashregister' THEN 1 
                        ELSE 0
                END AS "No of Manual Transactions"                                            
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
                ON cr.center = crt.crcenter
                AND cr.id = crt.crid                                                
        WHERE
                crt.crttype = 18
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate   
        UNION ALL
        --Cash Account Transactions
        SELECT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.crttype
                ,crt.employeecenter||'emp'||crt.employeeid AS "Employee ID"  
                ,empp.fullname AS "Employee Name"
                ,0 AS "Cash"                 
                ,0 AS "Credit Card"
                ,crt.amount AS "Cash account"
                ,0 AS "Other"
                ,CASE
                        WHEN cr.name = 'ManualCashregister' THEN 1 
                        ELSE 0
                END AS "No of Manual Transactions"                                               
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
                ON cr.center = crt.crcenter
                AND cr.id = crt.crid                                                
        WHERE
                crt.crttype = 5
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate 
        UNION ALL
        --Other Transactions
        SELECT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.crttype
                ,crt.employeecenter||'emp'||crt.employeeid AS "Employee ID"  
                ,empp.fullname AS "Employee Name"
                ,0 AS "Cash"                 
                ,0 AS "Credit Card"
                ,0 AS "Cash account"
                ,crt.amount AS "Other"
                ,CASE
                        WHEN cr.name = 'ManualCashregister' THEN 1 
                        ELSE 0
                END AS "No of Manual Transactions"                                                                    
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
                ON cr.center = crt.crcenter
                AND cr.id = crt.crid                                                               
        WHERE
                crt.crttype in (9,12,13,17,22)
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate                                              
        )t1
GROUP BY
        t1."Centre id"
        ,t1."Centre name"
        ,t1."Date"  
        ,t1."Employee ID"
        ,t1."Employee Name"                                     
