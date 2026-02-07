select distinct
p.center ||'p'|| p.id,
p.fullname,
r.relativecenter||'p'|| r.relativeid as relativeid,
CASE r.STATUS WHEN 0 THEN 'Lead' WHEN 1 THEN 'Active' WHEN 2 THEN 'Inactive' WHEN 3 THEN 'Blocked' ELSE 'Undefined' END AS relation_status


from persons p

left join relatives r
on
r.center = p.center
and 
r.id = p.id
and rtype = 1






where 

 p.persontype = 3
and ((r.relativecenter is null) or (r.STATUS not in (1,2)))
and p.status not in (7,8,4,5)