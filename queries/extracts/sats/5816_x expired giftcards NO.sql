Select c.center,
 c.id, 
c.subid,
c.owner_center || 'p' ||c.owner_id as memberid,
c.clips_left,
 c.clips_initial, LongToDate(c.valid_until) as expireDate , 
p.name, 
p.ptype

from 
CLIPCARDS C, products p

where
C.OWNER_CENTER >= 100 AND
C.OWNER_CENTER <= 199 and

p.center = c.center and
p.id = c.id and

c.clips_left > 0 and
c.finished =1 and
c.cancelled =0 
/* expiredate BETWEEN  :from AND 
:to */
