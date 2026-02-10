-- The extract is extracted from Exerp on 2026-02-08
--  
select
    s.owner_center as club_scope,
	c.name,
    s.owner_center||'p'||s.owner_id as customer,
    p.fullname as customer_name,
    s.start_date as subscription_start,
	srp.type,
	srp.state,
    srp.start_date as Free_start,
    srp.end_date as Free_end,
    s.BINDING_PRICE,
	srp.employee_center || 'emp' || srp.employee_id As Employee_Id,
	p2.fullname as EmployeeName,
    srp.text as "Comment",
	LONGTODATE(entry_time) as Registered
from
         persons p
    
join subscriptions s
    on
        p.center = s.owner_center
        and p.id = s.owner_id

Join centers c
	on
		p.center = c.id
    
join SUBSCRIPTION_REDUCED_PERIOD srp
    on
        s.center = srp.subscription_center
        and s.id = srp.subscription_id
join EMPLOYEES e
	on
		srp.employee_center = e.center and
		srp.employee_id = e.id
join PERSONS p2
	on p2.center = e.personcenter 
	and p2.id = e.personid
where
    s.owner_center in (:scope)
    and srp.type like 'FREE_ASSIGNMENT' 
    and (
			(
				srp.start_date >= :startDate 
				and srp.start_date <= :endDate
			) 
			or
			(
				srp.start_date < :startDate 
				and srp.end_date <= :endDate 
				and srp.end_date >= :startDate
			)
		)

order by
    s.owner_center,
    s.owner_id,
    srp.start_date
