Select
t3."missed classes during the last 60 days",
t4."Last missed class",
t4.total_amount||' DKK' as "fee amount"

from
(

select

count(t2.starttime) as "missed classes during the last 60 days",
t2.center,
t2.id


from
(


Select distinct
--rank() over(partition by p.center ||'p'||p.ID ORDER BY b.STARTTIME DESC) as rnk,
p.CENTER as CENTER,
p.id as ID,
p.CENTER ||'p'|| p.id as "PERSONKEY",
b.name,
longtodate(b.STARTTIME) as "starttime",
pg.PUNISHMENT,
par.NO_SHOW_UP_PUNISH_STATE,
pg.USAGE_PRODUCT,
longtodate(pu.plan_TIME) as "plantime",
par.center as parcenter,
par.id as parid,
pu.GRANT_ID,
pu.state,
trunc(longtodate(pu.PLAN_TIME)),
trunc(longtodate(pu.USE_TIME))

From Bookings b

join participations par 
on 
par.booking_center = b.center
and
par.booking_id = b.id
and par.state = 'CANCELLED'
and par.cancelation_reason in ('NO_SHOW')

Join persons p
on
par.PARTICIPANT_CENTER = p.center
and
par.PARTICIPANT_ID = p.id

join subscriptions s
on
s.owner_center = p.center
and s.owner_id = p.id 
and s.state in (2,4)

join subscriptiontypes st
on
s.subscriptiontype_center = st.center
and s.subscriptiontype_id = st.id

join privilege_usages pu
    on
        par.CENTER = pu.TARGET_CENTER
    AND par.ID = pu.TARGET_ID
   AND pu.TARGET_SERVICE = 'Participation'

JOIN PRIVILEGE_GRANTS pg
    ON
        pg.ID = pu.GRANT_ID

where
p.external_id in (:external_id)
and pg.PUNISHMENT in (1104,1105)
and pu.punishment_key is not null
and TRUNC(CURRENT_TIMESTAMP) <= longtodate(b.STARTTIME)+60 
and st.st_type = 1) t2

Group by
t2."PERSONKEY",
t2.center,
t2.id  )t3

left join
(
select

t1.starttime as "Last missed class",
t1.center,
t1.id,
t1.total_amount


from
(


Select distinct
rank() over(partition by p.center ||'p'||p.ID ORDER BY b.STARTTIME DESC) as rnk,
p.CENTER as CENTER,
p.id as ID,
p.CENTER ||'p'|| p.id as "PERSONKEY",
b.name,
longtodate(b.STARTTIME) as "starttime",
pg.PUNISHMENT,
par.NO_SHOW_UP_PUNISH_STATE,
pg.USAGE_PRODUCT,
longtodate(pu.plan_TIME) as "plantime",
par.center as parcenter,
par.id as parid,
pu.GRANT_ID,
pu.state,
trunc(longtodate(pu.PLAN_TIME)),
trunc(longtodate(pu.USE_TIME)),
invl.total_amount

From Bookings b

join participations par 
on 
par.booking_center = b.center
and
par.booking_id = b.id
and par.state = 'CANCELLED'
and par.cancelation_reason in ('NO_SHOW')
Join persons p
on
par.PARTICIPANT_CENTER = p.center
and
par.PARTICIPANT_ID = p.id

join subscriptions s
on
s.owner_center = p.center
and s.owner_id = p.id 
and s.state in (2,4)

join subscriptiontypes st
on
s.subscriptiontype_center = st.center
and s.subscriptiontype_id = st.id

join privilege_usages pu
    on
        par.CENTER = pu.TARGET_CENTER
    AND par.ID = pu.TARGET_ID
   AND pu.TARGET_SERVICE = 'Participation'
 --  and (pu.state in ('PLANNED') or (pu.state ='USED' and trunc(longtodate(pu.PLAN_TIME)) = trunc(longtodate(pu.USE_TIME))) ) 
JOIN PRIVILEGE_GRANTS pg
    ON
        pg.ID = pu.GRANT_ID
--and pg.USAGE_PRODUCT is not NULL

left join invoices inv
on inv.center ||'inv'|| inv.id = pu.punishment_key
and inv.center = pu.TARGET_CENTER
and inv.entry_time > b.STARTTIME

left join INVOICE_LINES_MT invl
 ON
     invl.CENTER = inv.center
     and invl.id = inv.id
     and invl.text = 'No Show fee'


where
p.external_id in (:external_id)
and pg.PUNISHMENT in (1104,1105)
and pu.punishment_key is not null
and TRUNC(CURRENT_TIMESTAMP) <= longtodate(b.STARTTIME)+60 
and st.st_type = 1
)t1
where t1.rnk = 1
)t4 on 
t4.center = t3.center
and
t4.id = t3.id
