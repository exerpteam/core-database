-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        t1."Centre id"
        ,t1."Centre name"
        ,t1."Date"
        ,SUM(t1."Total amount cash") AS "Total amount cash"
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
        SELECT DISTINCT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.amount AS "Total amount cash"
                ,crt.crttype
                ,CASE
                        WHEN cnl.center IS NOT NULL THEN 'Yes'
                        ELSE 'No'
                END AS returned
                ,inv.center
                ,inv.id 
        FROM
                cashregistertransactions crt
        JOIN
                centers c
                ON c.id = crt.center
        JOIN 
                params 
                ON params.CENTER_ID = c.id
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
                crt.crttype = 1
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate          
        UNION ALL
        SELECT DISTINCT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,-crt.amount AS "Total amount cash"
                ,crt.crttype
                ,CASE
                        WHEN cnl.center IS NOT NULL THEN 'Yes'
                        ELSE 'No'
                END AS returned
                ,inv.center
                ,inv.id 
        FROM
                cashregistertransactions crt
        JOIN
                centers c
                ON c.id = crt.center                
        JOIN 
                params 
                ON params.CENTER_ID = c.id
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
                crt.crttype = 4
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