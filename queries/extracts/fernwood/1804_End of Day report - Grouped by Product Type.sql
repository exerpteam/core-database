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
                                t2."Transaction Date"
                                ,t2."Group"
                                ,t2."Sum"
                                ,t2."Center"                 
                        FROM
                                (                
                                SELECT 
                                        t1."TransactionDate" AS "Transaction Date"
                                        ,sum(t1.Total) AS "Sum"
                                        ,t1."Product Group" AS "Group"
                                        ,t1."Center"
                                FROM
                                        (
                                        SELECT distinct 
                                                TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-DD') AS "TransactionDate"
                                                ,longtodateC(crt.transtime,crt.center)
                                                ,CASE
                                                        WHEN inl.total_amount != 0 THEN inl.total_amount
                                                        WHEN cnt.total_amount != 0 THEN -cnt.total_amount
                                                        ELSE 0
                                                END AS Total
                                                ,crt.customercenter||'p'||crt.customerid AS "Person ID"
                                                ,crt.employeecenter||'p'||crt.employeeid AS "Employee ID"
                                                ,CASE
                                                        WHEN pg.name is not null then pg.name
                                                        ELSE pgc.name
                                                END AS "Product Group"  
                                                ,CASE
                                                        WHEN pro.name is not null then pro.name
                                                        ELSE proc.name
                                                END AS product 
                                                ,c.name AS "Center"                                                                                                           
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
                                        JOIN 
                                                fernwood.centers c
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
                                        ,t1."Product Group" 
                                        ,t1."Center" 
                                )t2 
                        WHERE  t2."Sum" != 0                                                                        
       
                                
