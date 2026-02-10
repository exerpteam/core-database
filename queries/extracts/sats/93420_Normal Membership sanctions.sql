-- The extract is extracted from Exerp on 2026-02-08
--  
WITH pmp_xml AS (
        SELECT pp.id, CAST(convert_from(pp.configuration, 'UTF-8') AS XML) AS pxml FROM privilege_punishments pp 
)

Select distinct
t3."count: rolling sum",
t6."limittext" as "limit",
t4."Last missed class",
t3."restricted_until",
t6.restriction_value as rollingPeriodLength,
t6.restriction_count as afterMisuses

from
(

select

count(t2.starttime) as "count: rolling sum",
t2.center,
t2.id,
t2.br_stop_time as "restricted_until"

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
trunc(longtodate(pu.USE_TIME)),
longtodate(br.stop_time) as br_stop_time

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
left join booking_restrictions br
on
br.center = p.center
and
br.id = p.id    

and TRUNC(CURRENT_TIMESTAMP) < longtodate(br.stop_time)        

left join privilege_punishments pp
on
pp.id = pg.PUNISHMENT

where
p.external_id in (:external_id)
and pg.PUNISHMENT in (704,4)
and TRUNC(CURRENT_TIMESTAMP) <= longtodate(b.STARTTIME)+pp.restriction_value 
and st.st_type in (0,1)) t2

Group by
t2."PERSONKEY",
t2.center,
t2.id,
t2.br_stop_time  )t3

left join
(
select

t1.starttime as "Last missed class",
t1.center,
t1.id,
t1.PUNISHMENT


from
(


Select distinct
rank() over(partition by p.center ||'p'||p.ID ORDER BY b.STARTTIME DESC) as rnk,
p.CENTER as CENTER,
p.id as ID,
p.CENTER ||'p'|| p.id as "PERSONKEY",
b.name,
longtodate(b.STARTTIME) as "starttime",
pg.PUNISHMENT as PUNISHMENT,
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
and pg.PUNISHMENT in (704,4)
and TRUNC(CURRENT_TIMESTAMP) <= longtodate(b.STARTTIME)+30 
and st.st_type in (0,1)
)t1
where t1.rnk = 1
)t4 on 
t4.center = t3.center
and
t4.id = t3.id

left join
(
WITH pmp_xml AS (
        SELECT pp.id, CAST(convert_from(pp.configuration, 'UTF-8') AS XML) AS pxml FROM privilege_punishments pp 
)



select
cast(t5."limittext" as text),
cast(t5."limitid" as text),
t5.id,
t5.restriction_value,
t5.restriction_count

from
(
Select
UNNEST(xpath('//configuration/value//text()', pmp_xml.pxml))  as "limittext",
UNNEST(xpath('//configuration/value/@id', pmp_xml.pxml))  as "limitid",
pp2.id,
pp2.name,
pp2.restriction_count,
pp2.restriction_value

FROM 
                pmp_xml, privilege_punishments pp2
        WHERE pp2.id = pmp_xml.id
                   and pp2.id in (704,4)
                  
)t5 )t6 on t6.id = t4.PUNISHMENT and t6."limitid" = 'timeSpan3'

