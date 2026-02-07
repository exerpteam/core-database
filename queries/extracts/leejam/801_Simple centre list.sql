select
c.id,
c.shortname,
c.name

from 

centers c

where 
c.id IN ($$scope$$)