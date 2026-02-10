-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (   SELECT
            /*+ materialize */
            datetolongC(TO_CHAR(CAST(:From AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate
            ,CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
            ,c.id AS CENTER_ID
        FROM
            centers c
    )
SELECT
    t.transactionid AS Transaction_ID
    ,longtodatec(t.trans_time,t.center) as Transaction_date
    ,t.clearance_status AS clearTax_Status
FROM
    (   
        SELECT
            inv.center AS center , 
            inv.id     AS id , 
            inv.center||'inv'||inv.id AS transactionid,
            inv.trans_time as trans_time,
            inv.clearance_status
        FROM
            invoices inv
        JOIN
            params
        ON 
            params.center_id = inv.center
        WHERE
            inv.trans_time > params.FromDate
        
        UNION ALL
         
        SELECT
            cn.center AS center , 
            cn.id     AS id , 
            cn.center||'cred'||cn.id AS transactionid,
            cn.trans_time as trans_time,
            cn.clearance_status
        FROM
            credit_notes cn
        JOIN
            params
        ON 
            params.center_id = cn.center
        WHERE
            cn.trans_time > params.FromDate 
        )t
WHERE
        t.center NOT IN (101,111001,111004,112001,112002,113001,113002,114001,114002)
        AND
        t.center IN (:center)
ORDER BY
        t.trans_time
        
        