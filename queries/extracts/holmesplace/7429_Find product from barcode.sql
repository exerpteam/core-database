-- The extract is extracted from Exerp on 2026-02-08
--  
select identity, ref_globalid from  entityidentifiers 
where 
	ref_type = 4

and identity = :barcode
order by identity
