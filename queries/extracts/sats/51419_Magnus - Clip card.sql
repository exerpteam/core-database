Select *

from 
CLIPCARDS C, products p

where
C.OWNER_CENTER >= 500 AND
C.OWNER_CENTER <= 599 and

p.center = c.center and
p.id = c.id and

c.clips_left > 0 and
c.finished =0 and
c.cancelled =0

