WITH
  params AS
  (
      SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:from AS DATE), 'YYYY-MM-dd HH24:MI'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:to AS DATE) + INTERVAL '1 day'), 'YYYY-MM-dd HH24:MI'),c.id) - 1) AS BIGINT) AS ToDate
      FROM
          centers c
  )
SELECT 
        ar.customercenter||'p'||ar.customerid AS PersonID,
        art.* 
FROM 
        account_receivables ar
JOIN
        ar_trans art
        ON ar.center = art.center
        AND ar.id = art.id  
JOIN
        params
        on params.CENTER_ID = ar.center      
WHERE 

        art.text = 'Rejection Fee - Missing Payment Agreement'
        AND
        ar_type = 4
        AND 
        art.entry_time between params.FromDate AND params.ToDate