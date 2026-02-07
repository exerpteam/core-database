select 

p.center||'p'||p.id  AS MEMBER_ID

from persons p 

where  p.CITY = 'Coventry' and p.ZIPCODE = '20122'