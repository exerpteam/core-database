select distinct
p.center as club,
c.shortname as club_name,
p.center ||'p'|| p.id as id_socio, 
p.fullname as full_name,
prod.name as nome_clipcard,
TO_TIMESTAMP(cl.valid_from / 1000) as data_vendita_clip,
TO_TIMESTAMP(cl.valid_until / 1000) as data_scadenza_clip,
--cl.clips_left as clips_left,
case cl.finished 
	WHEN 'FALSE' THEN 'Active'
	WHEN 'TRUE' THEN 'Used'
END as status
from 
clipcards cl 
join products prod on cl.id = prod.id
JOIN PERSONS p ON p.CENTER = cl.OWNER_CENTER AND p.ID = cl.OWNER_ID
join centers c on c.id = p.center and c.country = 'IT'
where 
prod.center in ($$scope$$)
and prod.blocked = 0
AND prod.PTYPE = 4
and TO_TIMESTAMP(cl.valid_from / 1000) >= ($$venduta_dal$$)
--and prod.name in ('TEST', 'TEST1')

