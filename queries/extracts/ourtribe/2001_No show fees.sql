-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
params AS
        (
        SELECT
          /*+ materialize */
          datetolongC(TO_CHAR(CAST(:From AS DATE), 'dd-MM-yyyy'),c.id) AS FromDate,
          c.id AS CENTER_ID,
          CAST((datetolongC(TO_CHAR((CAST(:To AS DATE) + INTERVAL '1 day'), 'dd-MM-yyyy'),c.id) - 1) AS BIGINT) AS ToDate         
        FROM
          centers c)
Select
       inv.payer_center || 'p' || inv.payer_id AS "Memberid"
       ,TO_CHAR(longtodateC(art.trans_time,art.center), 'dd-mm-yyyy') AS "Date"
       , art.amount AS "Amount"
       , art.text AS "Reason"
       , art.employeecenter || 'p' || art.employeeid AS "Staff"
       , art.ref_type AS "Type"
       
        
FROM
       ar_trans art
LEFT JOIN
       invoices inv 
      ON 
      art.ref_center = inv.center 
      AND
      art.ref_id = inv.id
JOIN
        params
        ON params.CENTER_ID = art.ref_center                       
   WHERE 
  
   art.trans_time BETWEEN params.FromDate AND params.ToDate 
  -- longtodateC(art.trans_time,art.center) > '2022-04-01 00:00:01'
   --AND
 --  longtodateC(art.trans_time,art.center) < '2022-05-09 23:59:59'
 AND
  art.text like 'No Show Fee Sanction%'
    AND
   art.ref_type = 'INVOICE'
AND
inv.center in (:Scope)
   
Order by
"Memberid",
"Date"
