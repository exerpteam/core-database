select name,ID 
from centers c
where c.id IN ($$scope$$)