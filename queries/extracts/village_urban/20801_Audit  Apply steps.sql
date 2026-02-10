-- The extract is extracted from Exerp on 2026-02-08
--  
with 
params as materialized (
	select c.id as center,
		cast(datetolongc(to_char(to_date(:from_date, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss'), c.id) as bigint) as fromdate,
		cast(datetolongc(to_char(to_date(:to_date, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss'), c.id) as bigint) + (24 * 3600 * 1000) - 1 as todate
	from centers c
	--where c.id in (:scope)
	)

select 
        person_center||'p'||person_id                           as person_key,
        name                                                    as journal_name,
        length(convert_from(big_text, 'utf-8'))                 as note_length,
        creatorcenter||'emp'||creatorid                         as employee_key,		
        to_char(longtodatec(creation_time, person_center), 'YYYY-MM-DD HH24:MI:SS')               as creation_date,
        left(convert_from(big_text, 'utf-8'),250)||' [...]'        as note_details
        
from journalentries je
join params on params.center = je.person_center

where   je.creation_time between params.fromdate and params.todate
        and je.name ilike :journal_name
        AND (je.creatorcenter, je.creatorid) IN (:employee_key)  
        
order by 3 desc, 5 asc