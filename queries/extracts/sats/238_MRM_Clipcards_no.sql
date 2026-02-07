Select c.center, c.id, p.center||'p'||p.id memberid, c.owner_center, c.owner_id, c.clips_left, c.clips_initial, c.finished, c.cancelled, c.blocked, c.lastvaliddate, p.persontype, p.status

from 
CLIPCARDS C,
PERSONS P

where
C.OWNER_CENTER >= 101 AND
C.OWNER_CENTER <= 199 And
c.owner_id = p.id and
c.owner_center = p.center and
p.persontype <> 2
