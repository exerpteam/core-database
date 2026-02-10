-- The extract is extracted from Exerp on 2026-02-08
--  
Select * from products p
join roles r on p.requiredrole = r.id
where 
-- p.globalid = '7312850058012' AND 
p.requiredrole IS NOT NULL
AND p.blocked = false
AND r.blocked = true