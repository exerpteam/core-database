select 
bk.CENTER,
bk.ID,
to_char(longtodate(bk.STARTTIME), 'YYYY-MM-DD HH24:MI') as START_TIME,
to_char(longtodate(bk.STOPTIME), 'YYYY-MM-DD HH24:MI') as STOP_TIME,
bk.state,
bk.name,
cg.NAME as COLOUR_GROUP,
act_grp.NAME as ACTIVITY_GROUP,
bk.CLASS_CAPACITY
from bookings bk
join ACTIVITY act on bk.ACTIVITY = act.ID
join ACTIVITY top_act on ((act.TOP_NODE_ID is not null and top_act.ID = act.TOP_NODE_ID) or (act.TOP_NODE_ID is null and top_act.id=act.id))
join ACTIVITY_GROUP act_grp on act_grp.ID=top_act.ACTIVITY_GROUP_ID
join COLOUR_GROUPS cg on cg.ID = bk.COLOUR_GROUP_ID
where
bk.STARTTIME >= :From_date
and
bk.STARTTIME < (:To_date + 24*3600*1000)
and
bk.center >= :FromCenter
    and bk.center <= :ToCenter

order by 1,3,4,2