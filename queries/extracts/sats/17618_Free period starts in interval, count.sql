select 
    count(distinct s.owner_center||'p'||s.owner_id) as Customer
from 
    sats.subscription_reduced_period srd
join
    sats.subscriptions s
    on
    srd.subscription_center = s.center
    and srd.subscription_id = s.id
join
    sats.employees e
    on
    srd.employee_center = e.center
    and srd.employee_id = e.id
join
    sats.persons staff
    on
    e.personcenter = staff.center
    and e.personid = staff.id
where
     srd.START_DATE >= :from_date
    AND srd.start_Date <= :to_date
    AND s.owner_center in (:scope)
    and srd.state like 'ACTIVE' --remains active after periode over