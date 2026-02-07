select 
        c.name AS "Club Name"
        ,p.center || 'p' || p.id AS "PersonID"
        ,pr.req_amount AS "Requested Amount"
        ,pr.req_date AS "Request Date"
        ,pr.xfr_info As "Reject Reason"
	,ar.balance AS "Current Balance"
from 
        payment_requests  pr
JOIN
        account_receivables ar
        ON ar.center = pr.center 
        AND ar.id = pr.id
JOIN
        persons p
        ON p.center = ar.customercenter
        AND p.id = ar.customerid  
JOIN
        centers c
        ON c.id = p.center              
where 
        pr.request_type = 6
        AND 
        pr.state != 8
        AND
        pr.req_date Between :RequestDateFrom and :RequestDateTo
        AND
        p.Center in (:Scope)

 