-- The extract is extracted from Exerp on 2026-02-08
-- EC-4305
WITH params AS MATERIALIZED
(
        SELECT
                c.id
        FROM centers c 
        WHERE 
			c.id IN (:Scope)
			AND c.country = 'ES'
)
Select COALESCE(cast((pr.center) as varchar), 'In Total') as center, ch.name AS clearinghouse_name,sum(pr.req_amount), count(p.id)

from payment_requests pr
join params par on pr.center = par.id
JOIN vivagym.clearinghouses ch ON ch.id = pr.clearinghouse_id
JOIN
   Account_receivables ar
ON
   ar.center = pr.center
AND ar.id = pr.id

JOIN
   persons p
ON
   p.center = ar.customercenter
AND p.id = ar.customerid
join
clearing_out ci
on pr.req_delivery=ci.id
where pr.clearinghouse_id IN (201,3001,2801,3401,3801,3802,4401,4801,5001,4403,5401,5601,5801,6001,6201,7602,7601,7001,7201,7401,7202,6601,6801) --SEPA 
AND pr.request_type IN ('1','6') --payment,representation
AND ci.generated_date  between TO_DATE(:FromDate, 'YYYY-MM-DD')
AND TO_DATE(:ToDate, 'YYYY-MM-DD')   
Group by rollUP 
(pr.center,ch.name)
order by (case when pr.center is null then 1 else 2 end) desc