-- The extract is extracted from Exerp on 2026-02-08
--  
Select * from privilege_sets ps
join product_privileges pp on ps.id = pp.privilege_set
where ps.id = :priviligesetid