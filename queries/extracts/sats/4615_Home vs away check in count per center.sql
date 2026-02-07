select  c.name, count(*) as homevisits, 

(
select count (*)
from ECLUB2.CHECKIN_LOG ci, centers c1
where
ci.CHECKIN_TIME > :Check_in_from_date
and
ci.CHECKIN_TIME < (:Check_in_to_date + 24*3600*1000)
and
ci.center >= :FromCenter
    and ci.center <= :ToCenter
and ci.center = c1.id
and ci.center<>ci.CHECKIN_CENTER
group by c1.name
) awayvisits

from
ECLUB2.CHECKIN_LOG cl, centers c

where
cl.CHECKIN_TIME > :Check_in_from_date
and
cl.CHECKIN_TIME < (:Check_in_to_date + 24*3600*1000)
and
cl.center >= :FromCenter
    and cl.center <= :ToCenter
and cl.center = c.id
and cl.center=cl.CHECKIN_CENTER


group by c.name
order by c.name




