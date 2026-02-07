select
c.CENTER,
c.ID,
c.SUBID,
c.OWNER_CENTER,
c.OWNER_ID,
c.CLIPS_LEFT,
c.CLIPS_INITIAL,
c.FINISHED,
c.CANCELLED,
c.BLOCKED,
to_char(longtodate(c.VALID_FROM), 'YYYY-MM-DD HH24:MI') as VALID_FROM,
to_char(longtodate(c.VALID_UNTIL), 'YYYY-MM-DD HH24:MI') as VALID_UNTIL
from
    CLIPCARDS c
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
    and pers.center = c.OWNER_CENTER and pers.id = c.OWNER_ID
) and
c.OWNER_CENTER >= :FromCenter
    and c.OWNER_CENTER <= :ToCenter