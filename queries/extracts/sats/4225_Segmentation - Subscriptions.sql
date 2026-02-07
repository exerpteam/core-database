select
s.center,
s.id,
s.owner_center,
s.owner_id,
s.SUBSCRIPTIONTYPE_CENTER,
s.SUBSCRIPTIONTYPE_ID,
DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'NEW','UNKNOWN') as STATE,
DECODE (s.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED','UNKNOWN') AS SUB_STATE,
s.NOT_PAID,
to_char(s.BINDING_END_DATE, 'YYYY-MM-DD') as  BINDING_END_DATE,
s.BINDING_PRICE,
s.SUBSCRIPTION_PRICE,
to_char(s.START_DATE, 'YYYY-MM-DD') as  START_DATE,
to_char(s.END_DATE, 'YYYY-MM-DD')  as  END_DATE,
to_char(longtodate(s.CREATION_TIME), 'YYYY-MM-DD HH24:MI') as  CREATION_TIME
from
subscriptions s
where
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
    and (scl.BOOK_END_TIME >= datetolong(to_char(exerpsysdate()-3*365, 'YYYY-MM-DD HH24:MI')) or scl.BOOK_END_TIME is null)
    and pers.status not in (5,6) 
    and pers.sex != 'C'
    and pers.center = s.owner_center and pers.id = s.owner_id
) and
s.center >= :FromCenter
    and s.center <= :ToCenter

