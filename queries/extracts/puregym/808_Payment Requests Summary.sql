-- The extract is extracted from Exerp on 2026-02-08
--  
select c.id, c.NAME, decode(pr.REQUEST_TYPE, 1, 'Normal', 6, 'Representation', 5, 'Refund') as RequestType,
sum(case when pr.state in (1,2) then 1 else 0 end) as Pending,
sum(case when pr.state in (3,4,18) then 1 else 0 end) as Paid,
sum(case when pr.state in (5,6,7,17) then 1 else 0 end) as Rejected,
sum(case when pr.state in (12, 19) then 1 else 0 end) as NotSent,
count(*) as total

from PUREGYM.PAYMENT_REQUESTS pr 
join centers c on c.id = pr.center
where 
pr.req_date >= :from_date and pr.req_date <= :to_date
and pr.REQUEST_TYPE in (1,6,5) and pr.STATE not in (8)
and pr.center in (:scope)
group by c.id, c.name, pr.REQUEST_TYPE
order by pr.REQUEST_TYPE