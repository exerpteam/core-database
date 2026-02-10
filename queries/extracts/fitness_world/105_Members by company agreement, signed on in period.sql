-- The extract is extracted from Exerp on 2026-02-08
--  
select 
	s.owner_center||'p'||s.owner_id as Kunde, 
	to_char(s.start_date, 'DD-MM-YYYY') as StartDato,
	p.firstname||' '||p.lastname as customerName
from 
	 fw.subscriptions s 
join fw.persons p 
	on s.owner_center = p.center 
	and s.owner_id = p.id
join fw.relatives rel 
	on p.center = rel.center 
	and p.id = rel.id 
	and rel.rtype = 3
where
	rel.relativecenter = :RelativeCenterId
and rel.relativeid = :RelativeId
and rel.relativesubid = :RelativeSubId
and rel.status = :Agreement_Status
and s.start_date between :from_date and :to_date