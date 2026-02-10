-- The extract is extracted from Exerp on 2026-02-08
--  
select
	table_name,
	column_name, 
	data_type, 
	character_maximum_length
from 
	INFORMATION_SCHEMA.COLUMNS 
