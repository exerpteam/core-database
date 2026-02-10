-- The extract is extracted from Exerp on 2026-02-08
--  
with c as (
SELECT table_name, ordinal_position, 
 column_name|| ' ' || data_type col
, row_number() over (partition by table_name order by ordinal_position asc) rn
, count(*) over (partition by table_name) cnt
FROM information_schema.columns
-- WHERE table_name   in ('subscriptionperiodparts', 'spp_invoicelines_link')
WHERE table_name   in (
SELECT DISTINCT t.table_name
FROM	 INFORMATION_SCHEMA.TABLES AS t
/*
	JOIN INFORMATION_SCHEMA.COLUMNS AS c
		ON		t.table_schema = c.table_schema 
			AND t.table_name = c.table_name
*/
LIMIT 10
)
order by table_name, ordinal_position
)
select case when rn = 1 then 'create table ' || table_name || '(' else '' end
 || col 
 || case when rn < cnt then ',' else '); '  end
from c 
order by table_name, rn asc;
