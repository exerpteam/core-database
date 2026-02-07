select 
		c.name,
		P.Name,
		p.coment
from 
	products p
join
	centers c on c.id = p.center
where
	p.ptype = 10 

AND 
	(p.name LIKE '%Multi%'
OR 
	p.coment LIKE '%Multi%')




