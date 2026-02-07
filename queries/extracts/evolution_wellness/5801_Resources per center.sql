Select
c.name,
br.name,
br.type
from booking_resources br
join centers c on br.center = c.id