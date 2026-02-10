-- The extract is extracted from Exerp on 2026-02-08
--  
select
    count(distinct(p.center||'p'||p.id)) as count_of_companies,
    to_char(longtodate(stl.entry_start_time), 'YYYY-MM-dd') as entry_date
from
    fw.persons p
join fw.state_change_log stl
    on
    p.center = stl.center
    and p.id = stl.id
where
    p.sex = 'C'
    and stl.entry_type = 1
    and stl.entry_start_time >=	:creation_from
	and stl.entry_start_time <=	:creation_to
    and p.center in (:center)
group by
    to_char(longtodate(stl.entry_start_time), 'YYYY-MM-dd') 
