select 
count(*) from SUBSCRIPTIONS s
join persons p on s.owner_center = p.center and s.owner_id = p.id
where s.state IN (2,4) and PERSONTYPE not in (2,9)