-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-11745
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
                                        p.center || 'p' || p.id AS "ExerpId"
                                        ,p.fullname AS "Name"
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
                                        ,pr.req_date AS "Date"
                                        ,CASE
                                                pr.request_type
                                                WHEN 1 THEN 'Payment Request'
                                                WHEN 2 THEN 'Debt Collection'
                                                WHEN 3 THEN 'Reversal'
                                                WHEN 4 THEN 'Reminder'
                                                WHEN 5 THEN 'Refund Request'
                                                WHEN 6 THEN 'Representation Request'
                                                WHEN 7 THEN 'Legacy'
                                                WHEN 8 THEN 'Zero'
                                                WHEN 9 THEN 'Service Charge'
                                        END AS "Type"  
                                        ,pr.center AS "Center" 
                                        ,pr.req_delivery AS "File ID"    
					,CASE
						WHEN pr.clearinghouse_id = 2 THEN TO_CHAR(longtodateC(pr.last_modified,pr.center),'YYYY-MM-DD HH24:MI') 
						ELSE NULL
				        END AS "Date and Time" 
				        ,'N/A' AS "Employee Name"
                                        ,'N/A' AS "Employee Person ID"                                                      
FROM 
        payment_agreements pag 
JOIN 
        account_receivables ar ON ar.center = pag.center AND ar.id = pag.id
JOIN 
        persons p ON p.center = ar.customercenter AND p.id = ar.customerid
JOIN 
        payment_requests pr ON pr.center = pag.center AND pr.id = pag.id AND pr.agr_subid = pag.subid AND pr.state <> 8
JOIN 
        centers c ON c.id = pr.center         
WHERE 
        pr.req_date between :From and :To
        AND 
        pr.center IN (:Scope)
        AND
        pr.request_type NOT IN (2,4,8) 
UNION ALL
SELECT 
        p.center ||'p'||p.id AS "ExerpID"
        ,p.fullname AS "Name"
        ,art.text AS "Reference"
        ,c.shortname AS "Club"
        ,art.amount AS "Amount"
        ,art.status AS "State"
        ,CAST(longtodatec(art.entry_time,art.center) AS Date) AS "Date"
        ,art.ref_type AS "Type"
        ,art.center AS "Center"
        ,0 AS "File ID"
        ,TO_CHAR(longtodateC(art.entry_time,art.center),'YYYY-MM-DD HH24:MI') AS "Date and Time"
        ,pemp.fullname AS "Employee Name"
        ,pemp.center ||'p'||pemp.id as "Employee Person ID"     
FROM
        ar_trans art      
JOIN
        account_receivables ar
        ON ar.center = art.center
        AND ar.id = art.id
JOIN
        persons p
        ON p.center = ar.customercenter                      
        AND p.id = ar.customerid                                                               
JOIN
        centers c
        ON c.id = p.center
LEFT JOIN
        employees emp
        ON emp.center = art.employeecenter
        AND emp.id = art.employeeid
LEFT JOIN
        persons pemp
        ON pemp.center = emp.personcenter
        AND pemp.id = emp.personid 
JOIN 
        params 
        ON params.CENTER_ID = p.center                                 
WHERE
        art.ref_type in ('ACCOUNT_TRANS')
        AND 
        (art.text like '%recouped%'
        or 
        art.text like 'Manual registered payment of reques%'
        or 
        art.text = 'Payment for sale'
        or
        art.text = 'Payment into account'
        or
        art.text = 'Payment revoked manually')
        AND 
        p.center in (:Scope)
        AND art.entry_time BETWEEN params.FromDate AND params.ToDate  
        AND 
        art.employeecenter is not null 
        AND    
        art.employeecenter||'emp'||art.employeeid != '100emp1'                         