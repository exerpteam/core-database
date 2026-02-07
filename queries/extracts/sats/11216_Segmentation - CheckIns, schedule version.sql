select
ci.CENTER,
ci.ID,
ci.SUBID,
ci.CHECKIN_CENTER,
to_char(eclub2.longtodate(ci.CHECKIN_TIME), 'YYYY-MM-DD HH24:MI') as CHECKIN_TIME
from ECLUB2.CHECKIN_LOG ci
where
/*exists (
select 
    1
from 
    ECLUB2.STATE_CHANGE_LOG scl
join 
    eclub2.persons pers on pers.center=scl.center and pers.id = scl.id 
where 
    scl.ENTRY_TYPE = 1 
    and scl.STATEID = 1
    and scl.ENTRY_START_TIME >= eclub2.datetolong(to_char(exerpsysdate()-3*365, 'YYYY-MM-DD HH24:MI'))
    and pers.status not in (5,6) 
    and pers.sex != 'C'
    and pers.center = ci.CENTER and pers.id = ci.ID
) and*/
ci.CHECKIN_TIME  >= eclub2.datetolong(to_char(exerpsysdate() - :Days_back_in_time,
'yyyy-mm-dd HH24:MI'))
and
ci.CHECKIN_TIME <= (eclub2.datetolong(to_char(exerpsysdate() - 1, 'yyyy-mm-dd HH24:MI'))
+ 24*3600*1000)
and
ci.center >= :FromCenter
    and ci.center <= :ToCenter
order by 1