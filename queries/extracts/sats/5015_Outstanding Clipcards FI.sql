Select c.center, c.id, c.subid,c.owner_center, c.owner_id, p.id, c.clips_left, c.clips_initial, LongToDate(c.valid_until), c.owner_center||'p'||c.owner_id AS MemberId, p.name, p.ptype

from 
CLIPCARDS C, products p

where
C.OWNER_CENTER >= 700 AND
C.OWNER_CENTER <= 799 and

p.center = c.center and
p.id = c.id and

c.clips_left > 0 and
c.finished =0 and
c.cancelled =0

