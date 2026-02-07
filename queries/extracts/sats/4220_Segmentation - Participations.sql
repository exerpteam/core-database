select
pa.PARTICIPANT_CENTER,
pa.PARTICIPANT_ID,
pa.PARTICIPATION_NUMBER,
to_char(longtodate(pa.START_TIME), 'YYYY-MM-DD HH24:MI') as START_TIME,
to_char(longtodate(pa.STOP_TIME), 'YYYY-MM-DD HH24:MI') as STOP_TIME,
pa.BOOKING_CENTER,
pa.BOOKING_ID,
pa.STATE,
pa.CANCELATION_REASON
from PARTICIPATIONS pa

where
/*
exists (
select 
    1
from 
    STATE_CHANGE_LOG scl
join 
    persons pers on pers.center=scl.center and pers.id = scl.id 
where 
    scl.ENTRY_TYPE = 1 
    and scl.STATEID = 1
    and scl.ENTRY_START_TIME >= datetolong(to_char(exerpsysdate()-3*365, 'YYYY-MM-DD HH24:MI'))
    and pers.status not in (5,6) 
    and pers.sex != 'C'
    and pers.center = pa.PARTICIPANT_CENTER and pers.id = pa.PARTICIPANT_ID
) and*/
pa.START_TIME >= :From_date
and
pa.START_TIME < (:To_date + 24*3600*1000)
and
pa.participant_center >= :FromCenter
    and pa.participant_center <= :ToCenter
