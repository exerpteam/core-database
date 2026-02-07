Select
e.last_login AS LAST_LOGIN,
c.name AS CENTER_NAME,
p.fullname AS STAFF_NAME,
*
from employees e
join persons p 
on p.center = e.personcenter
AND p.id = e.personid
join centers c 
ON e.personcenter = c.id