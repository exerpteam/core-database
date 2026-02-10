-- The extract is extracted from Exerp on 2026-02-08
--  
select p.STATUS,c.*
from cashcollectioncases c
join persons p ON c.PERSONCENTER = p.CENTER AND c.PERSONID = p.ID
where c.closed = 0
and c.hold = 1
and c.missingpayment = 1
AND p.STATUS NOT IN (4,5,7,8)