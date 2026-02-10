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
            )                    

SELECT distinct
        c.id AS center,
		ar.customercenter || 'p' || ar.customerid AS PersonId,
		c.name,
	pr.creditor_id AS Clearinghouse,
        art.text,
       art.amount,
       longtodate(art.trans_time) as entrytime
        
FROM
         ar_trans art 


JOIN account_receivables ar 
ON art.center = ar.center 
AND art.id = ar.id

JOIN
    params
 ON
    params.CenterID = art.center
       
left JOIN 
        payment_request_specifications prs
ON art.payreq_spec_center = prs.center 
AND art.payreq_spec_id = prs.id 
AND art.payreq_spec_subid = prs.subid        

left join        
payment_requests pr        
ON pr.inv_coll_center = prs.center 
AND pr.inv_coll_id = prs.id 
AND pr.inv_coll_subid = prs.subid

left JOIN centers c 
ON ar.customercenter = c.id


WHERE
art.employeecenter = 100 and art.employeeid = 4001               
and ((art.text = 'API Register remaining money from payment request') or (art.text = 'Manuel registrering af betaling: '))
and art.trans_time >= params.from_date
AND art.trans_time <= params.to_date