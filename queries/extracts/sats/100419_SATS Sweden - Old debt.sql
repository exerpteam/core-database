WITH
        params AS materialized
    (
         SELECT
                (current_date - interval '1 year')::date  AS FromDate,
                current_date AS ToDate,
                c.id  AS centerid
         FROM
            centers c
         WHERE
            c.country = 'SE'  
            and c.id IN (:scope)
    )
 
SELECT DISTINCT
              p.center||'p'||p.id               as "member ID",
              op.center||'p'||op.id             as "other payer ID",              
              prs.requested_amount              as "debt amount",  
              ccr.req_date                      as "date",
              prs.ref                           as "invoice number",
              latestsub.SUBSCRIPTION_STATE      as "latest subscription state"             

FROM PAYMENT_REQUEST_SPECIFICATIONS prs

JOIN PAYMENT_REQUESTS pr 
        ON prs.center = pr.inv_coll_center
	AND prs.id = pr.inv_coll_id
	AND prs.subid = pr.inv_coll_subid
	
JOIN ACCOUNT_RECEIVABLES ar 
        ON pr.CENTER = ar.CENTER
	AND pr.ID = ar.ID
	AND ar.ar_type = 4
	
JOIN PERSONS p 
        ON p.CENTER = ar.customercenter
	AND p.ID = ar.customerid
	
JOIN params
        ON params.centerid = p.center	
	
JOIN cashcollection_requests ccr 
        ON ccr.prscenter = prs.center
	AND ccr.prsid = prs.id
	AND ccr.prssubid = prs.subid

---other payer 
LEFT JOIN relatives op
        ON p.center = op.relativecenter
        AND p.id = op.relativeid
        AND op.rtype = 12 --- 12 Other payer
        AND op.status = 1 --- 1 Active
    
left JOIN --- subquery ranking the member's subscriptions with latest as 1
     (
         SELECT
             sub.owner_center as per_center,
             sub.owner_id as per_id,
             sub.end_date,
             sub.id,
             sub.center,
             CASE sub.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' 
             END AS SUBSCRIPTION_STATE,             
             ROW_NUMBER() OVER (PARTITION BY sub.owner_center, sub.owner_id ORDER BY sub.end_date DESC) ranked
         FROM
             subscriptions sub
     ) latestsub
 ON
     p.center = latestsub.per_center
 AND p.id = latestsub.per_id
-- AND latestsub.center = s.center
-- AND latestsub.id = s.id
   
      
WHERE 1=1 
        AND latestsub.ranked = 1 --- latest subscription
        and prs.open_amount > 0 --- unpaid debt only
        and p.status = 2 --- 2 Inactive
        and ccr.req_date between params.fromdate and params.todate --- between today and -1 year  
--	and ccr.req_date < params.fromdate --- before 1 year ago
 
order by 1, 4 asc