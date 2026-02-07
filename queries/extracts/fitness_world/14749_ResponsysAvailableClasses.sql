-- This is the version from 2026-02-05
--  
select distinct bk.center, bk.NAME as Class, agr.NAME as Category
from FW.BOOKINGS bk
join FW.ACTIVITY act on bk.ACTIVITY = act.id
join FW.ACTIVITY_GROUP agr on act.ACTIVITY_GROUP_ID = agr.ID
where bk.STARTTIME > datetolong(to_char(trunc(exerpsysdate())+1, 'YYYY-MM-DD HH24:MI')) and bk.STARTTIME < datetolong(to_char(trunc(exerpsysdate())+29, 'YYYY-MM-DD HH24:MI'))
and bk.state = 'ACTIVE' and act.ACTIVITY_TYPE = 2
order by 1, 3, 2