-- The extract is extracted from Exerp on 2026-02-08
--  
select * from entityidentifiers e 
where
e.IDMETHOD = 1
AND e.REF_TYPE = 4
AND e.ENTITYSTATUS = 1