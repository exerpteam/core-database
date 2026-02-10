-- The extract is extracted from Exerp on 2026-02-08
-- Find members who have the Coventry zipcode assigned 
select 

p.center||'p'||p.id  AS MEMBER_ID

from persons p 

where  p.CITY = 'Coventry' and p.ZIPCODE = '20122'