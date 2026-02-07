-- This is the version from 2026-02-05
--  
select
    count(distinct(p.center||'p'||p.id)) as customerID,
    to_char(eclub2.longtodate(stl.entry_start_time), 'YYYY-MM-dd') as entry_date
from
    eclub2.persons p
join eclub2.state_change_log stl
    on
    p.center = stl.center
    and p.id = stl.id
where
    p.sex = 'C'
    and stl.entry_type = 1
    and to_char(eclub2.longtodate(stl.entry_start_time), 'YYYY-MM-dd') = to_char( 
    :creation_date , 'YYYY-MM-dd')
    and p.center in (:center)
group by
    stl.entry_start_time