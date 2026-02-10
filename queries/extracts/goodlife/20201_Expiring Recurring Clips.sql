-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
	c.owner_center || 'p' || c.owner_id AS PersonID, 
	c.clips_initial, 
	c.clips_left,
	TO_CHAR(LongtodateC(c.valid_from, c.center),'YYYY-MM-DD') AS CreatedDate,
	TO_CHAR(LongtodateC(c.valid_until, c.center),'YYYY-MM-DD') AS ExpiryDate 
	
FROM clipcards c

WHERE c.clips_left > 0

AND c.finished = 'f'

AND c.cancelled = 'f'

AND c.id IN
('1508',
'1517',
'1499',
'1513',
'1505',
'1510',
'1511',
'1514',
'1519',
'1516',
'1507',
'28201',
'1740')

AND LongtodateC (c.valid_until, c.center) <= ($$ExpiryDate$$)
