Select
t3."missed classes during the entire prepaid period",
t4."Last missed class"

from
(

select

count(t2.starttime) as "missed classes during the entire prepaid period",
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
and pg.PUNISHMENT = 1304
and s.start_date <= longtodate(b.STARTTIME) and s.end_date >= longtodate(b.STARTTIME)
and st.st_type = 0) t2

Group by
t2."PERSONKEY",
t2.center,
t2.id  )t3

left join
(
select

t1.starttime as "Last missed class",
t1.center,
t1.id



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
 --  and (pu.state in ('PLANNED') or (pu.state ='USED' and trunc(longtodate(pu.PLAN_TIME)) = trunc(longtodate(pu.USE_TIME))) ) 
JOIN PRIVILEGE_GRANTS pg
    ON
        pg.ID = pu.GRANT_ID
--and pg.USAGE_PRODUCT is not NULL
where
p.external_id in (:external_id)
and pg.PUNISHMENT = 1304
and s.start_date <= longtodate(b.STARTTIME) and s.end_date >= longtodate(b.STARTTIME)
and st.st_type = 0
)t1
where t1.rnk = 1
)t4 on 
t4.center = t3.center
and
t4.id = t3.id

