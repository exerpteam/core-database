-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
            params AS
            (
             SELECT
                    /*+ materialize */
                    --TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')) AS cutDate,
                    datetolongC(TO_CHAR(TO_DATE(:fromDate,'YYYY-MM-DD'), 'YYYY-MM-DD'), c.ID) AS from_date,
                    datetolongC(TO_CHAR(TO_DATE(:toDate,'YYYY-MM-DD'),  'YYYY-MM-DD'), c.ID)+ (86400 * 1000)-1 AS to_date,
                    c.ID                      AS CenterID
               FROM
                    CENTERS c
				WHERE
				c.country = 'ES'
            )


SELECT
        c.id AS center,
		ar.customercenter || 'p' || ar.customerid AS PersonId,
		c.name,
		case when arm.amount is null
		then art.amount
		else arm.amount end AS Amount,
		case when arm.amount is null
		then longtodate(art.trans_time)
		Else pr.req_date END AS fecha_emision,
		case when longtodatec(arm.entry_time, art.center) is null
	then longtodatec(art.entry_time, art.center)
	else longtodatec(arm.entry_time, art.center) end AS fecha_recuperacion,
pr.creditor_id AS Clearinghouse,
        art.text
       
       
        
FROM
        vivagym.payment_requests pr
JOIN 
        payment_request_specifications prs
ON pr.inv_coll_center = prs.center 
AND pr.inv_coll_id = prs.id 
AND pr.inv_coll_subid = prs.subid

JOIN ar_trans art 
ON art.payreq_spec_center = prs.center 
AND art.payreq_spec_id = prs.id 
AND art.payreq_spec_subid = prs.subid

JOIN
    params
 ON
    params.CenterID = art.center

JOIN vivagym.account_receivables ar 
ON art.center = ar.center 
AND art.id = ar.id

JOIN vivagym.centers c 
ON ar.customercenter = c.id

left JOIN ART_MATCH arm
ON
arm.ART_PAID_CENTER = art.CENTER
AND arm.ART_PAID_ID = art.ID
AND arm.ART_PAID_SUBID = art.SUBID


WHERE
    (
		((pr.state = 4) OR (pr.state = 3 AND pr.request_type = 6)) 
		AND arm.entry_time > pr.entry_time
		AND arm.entry_time >= params.from_date 
	AND arm.entry_time <= params.to_date  
         AND art.collected not in (3) and arm.CANCELLED_TIME IS NULL)
         
         
        or    (pr.state in (17) and pr.request_type = 6 and pr.last_modified >= params.from_date AND arm.entry_time > pr.entry_time
		AND arm.entry_time >= params.from_date 
		AND arm.entry_time <= params.to_date  AND art.collected not in (3) and arm.CANCELLED_TIME-1> params.to_date) 
	
	or    (art.text = 'API Register remaining money from payment request' and art.entry_time > params.from_date and art.entry_time < params.to_date)   