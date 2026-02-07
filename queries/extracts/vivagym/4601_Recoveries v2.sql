SELECT
        c.id AS center,
		ar.customercenter || 'p' || ar.customerid AS PersonId,
		c.name,
		arm.amount AS Amount,
		pr.req_date AS fecha_emision,
		longtodatec(arm.entry_time, art.center)AS fecha_recuperacion,
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

JOIN vivagym.account_receivables ar 
ON art.center = ar.center 
AND art.id = ar.id

JOIN vivagym.centers c 
ON ar.customercenter = c.id
AND c.country = 'ES'
JOIN ART_MATCH arm
ON
arm.ART_PAID_CENTER = art.CENTER
AND arm.ART_PAID_ID = art.ID
AND arm.ART_PAID_SUBID = art.SUBID
--AND (arm.CANCELLED_TIME IS NULL )

WHERE
    (
		((pr.state = 4) OR (pr.state = 3 AND pr.request_type = 6)) 
		AND arm.entry_time > pr.entry_time
		AND arm.entry_time >= CAST(datetolong(TO_CHAR(TO_DATE(:From, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS bigint)
	AND arm.entry_time <= CAST(datetolong(TO_CHAR(TO_DATE(:To, 'YYYY-MM-DD')  + interval '1 day', 'YYYY-MM-DD')) AS bigint)
         AND art.collected not in (3) and arm.CANCELLED_TIME IS NULL)
         
         
        or    (pr.state in (17) and pr.request_type = 6 and longtodate(pr.last_modified) >= :To AND arm.entry_time > pr.entry_time
		AND arm.entry_time >= CAST(datetolong(TO_CHAR(TO_DATE(:From, 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS bigint)
		AND arm.entry_time <= CAST(datetolong(TO_CHAR(TO_DATE(:To, 'YYYY-MM-DD')  + interval '1 day', 'YYYY-MM-DD')) AS bigint)  AND art.collected not in (3) and longtodate(arm.CANCELLED_TIME)-1> :To) 
