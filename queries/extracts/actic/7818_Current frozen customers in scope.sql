select
    s.owner_center as club_scope,
	c.name,
    s.owner_center||'p'||s.owner_id as customer,
    p.fullname as customer_name,
    s.start_date as subscription_start,
    sfp.start_date as freeze_start,
    sfp.end_date as freeze_end,
	current_date As Current_date,
	sfp.employee_center || 'emp' || sfp.employee_id As EmployeeID,
	p2.fullname	As EmployeeName,
	sfp.text
from
         persons p
    join subscriptions s
    on
        p.center = s.owner_center
        and p.id = s.owner_id

Join centers c
ON 
p.center = c.id

    join subscription_freeze_period sfp
    on
        s.center = sfp.subscription_center
        and s.id = sfp.subscription_id
join Employees e on
	sfp.employee_center = e.center and
	sfp.employee_id = e.id
join Persons p2 on
	e.personcenter = p2.center and
	e.personid = p2.id
where
    s.owner_center in (:scope)
    and s.state = 4 -- frozen
    and current_date >= sfp.start_date
    and current_date <= sfp.end_date +1
order by
    s.owner_center,
    s.owner_id,
    sfp.start_date
