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
        SELECT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,crt.amount AS "Total amount cash"
                ,crt.crttype
        FROM
                cashregistertransactions crt
        JOIN
                centers c
                ON c.id = crt.center
        JOIN 
                params 
                ON params.CENTER_ID = c.id                                
        WHERE
                crt.crttype = 1
                AND 
                crt.amount != 0
                AND 
                crt.center IN (:Scope)
                AND
                crt.transtime BETWEEN params.FromDate AND params.ToDate          
        UNION ALL
        SELECT
                crt.center AS "Centre id"
                ,c.shortname AS "Centre name"
                ,TO_CHAR(longtodateC(crt.transtime,crt.center),'YYYY-MM-dd')  AS "Date"
                ,-crt.amount AS "Total amount cash"
                ,crt.crttype
        FROM
                cashregistertransactions crt
        JOIN
                centers c
                ON c.id = crt.center                
        JOIN 
                params 
                ON params.CENTER_ID = c.id                                
        WHERE
                crt.crttype = 4
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
