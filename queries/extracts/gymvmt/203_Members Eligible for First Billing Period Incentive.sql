-- The extract is extracted from Exerp on 2026-02-08
-- Members Eligible for First Billing Period
WITH params as (
SELECT
     c.id as centerId,
     TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') as currentdate,
     datetolong((TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD') - INTERVAL '12 months') :: text) as cutdate
from
    centers c

),
eligible_members as(
select 
    p.center,
    p.id,
    s.center as sub_center,
    s.id as sub_id,
    s.billed_until_date + INTERVAL '1 day' as free_period_start,
    s.billed_until_date + INTERVAL '15 days' as free_period_end,
    params.cutdate
from
params
join
persons p
on params.centerId = p.center
join
person_ext_attrs pea
on p.center = pea.personcenter
and p.id = pea.personid
join subscriptions s
on s.owner_center = p.center
and s.owner_id = p.id
join products prod
on s.subscriptiontype_center = prod.center
and s.subscriptiontype_id = prod.id
join product_and_product_group_link ppg
on ppg.product_center = prod.center
and ppg.product_id = prod.id
join product_group pg
on ppg.product_group_id = pg.id
where 
pea.name = 'FVI'
and pea.txtvalue = 'Yes'
and pg.name = 'FVI'
and longtodateC(s.creation_time, s.center) = params.currentdate
)
(select
em.center,
em.id,
em.sub_id,
em.sub_id,
em.free_period_start,
em.free_period_end
from
eligible_members em
JOIN clipcards cc
on cc.owner_center = em.center
and cc.owner_id = em.id
JOIN products prod
on cc.center = prod.center
and cc.id = prod.id
where 
prod.name IN (

'Drop in Fee',

'Guest Drop In Fee')
and cc.valid_from > em.cutdate
and cc.center = NULL
)
UNION ALL
(
select
em.center,
em.id,
em.sub_center,
em.sub_id,
em.free_period_start,
em.free_period_end
from
eligible_members em
JOIN subscriptions s
on s.owner_center = em.center
and s.owner_id = em.id
JOIN products prod
on s.subscriptiontype_center = prod.center
and s.subscriptiontype_id = prod.id
where 
prod.name IN (
'Guest Pass - 14 Day',

'Guest Pass - 7 Day',

'Guest Pass - 3 Day',

'Guest Pass - 10 Day'
)
and s.center = NULL
and s.creation_time > em.cutdate
)

