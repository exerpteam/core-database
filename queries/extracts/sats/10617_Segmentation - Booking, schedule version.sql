select 
bk.CENTER,
bk.ID,
to_char(eclub2.longtodate(bk.STARTTIME), 'YYYY-MM-DD HH24:MI') as START_TIME,
to_char(eclub2.longtodate(bk.STOPTIME), 'YYYY-MM-DD HH24:MI') as STOP_TIME,
bk.state,
bk.name,
cg.NAME as COLOUR_GROUP,
act_grp.NAME as ACTIVITY_GROUP,
bk.CLASS_CAPACITY
from eclub2.bookings bk
join ECLUB2.ACTIVITIES_NEW act on bk.ACTIVITY = act.ID
join ECLUB2.ACTIVITIES_NEW top_act on ((act.TOP_NODE_ID is not null and top_act.ID = act.TOP_NODE_ID) or (act.TOP_NODE_ID is null and top_act.id=act.id))
join ECLUB2.ACTIVITY_GROUPS_NEW act_grp on act_grp.ID=top_act.ACTIVITY_GROUP_ID
join ECLUB2.COLOUR_GROUPS cg on cg.ID = bk.COLOUR_GROUP_ID
where
bk.STARTTIME >= eclub2.datetolong(to_char(exerpsysdate() - :Days_back_in_time, 'yyyy-mm-dd HH24:MI'))
and
bk.STARTTIME <= (eclub2.datetolong(to_char(exerpsysdate() - 1, 'yyyy-mm-dd HH24:MI')) + 24*3600*1000)
and
bk.center >= :FromCenter
    and bk.center <= :ToCenter

order by 1,3,4,2