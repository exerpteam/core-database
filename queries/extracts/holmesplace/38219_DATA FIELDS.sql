-- The extract is extracted from Exerp on 2026-02-08
-- Get fields from tables. Put table name in small letters
select 
	column_name, 
	data_type, 
	character_maximum_length
from 
	INFORMATION_SCHEMA.COLUMNS 
where 
	table_name = 'account_receivables'