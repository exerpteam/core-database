-- This is the version from 2026-02-05
--  
Select * from privilege_sets ps
join product_privileges pp on ps.id = pp.privilege_set
where ps.id = :priviligesetid