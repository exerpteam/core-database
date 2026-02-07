select 
    stl.center||'p'||stl.id as persons,
	longtodate(stl.entry_start_time)
from 
    persons p
join
    state_change_log stl
    on
    p.center = stl.center
    and p.id = stl.id
join
    subscriptions s
    on
    p.center = s.owner_center
    and p.id = s.owner_id
join
    journalentries j
    on
    p.center = j.person_center
    and p.id = j.person_id
    and j.jetype = 3 and j.person_subid = 1 
join 
    state_change_log stl2
    on
        s.center = stl2.center
    and s.id     = stl2.id
    and stl2.entry_type = 2 and stl2.stateid = 2 
where
    stl.entry_type = 3
and p.center in (:scope)
and stl.entry_start_time between (:from_date) and (:to_date)
and p.status in (:person_status)
and s.state in (:subscription_state)
and to_char(longtodate(stl.entry_start_time),'YYYY-MM-dd') 
	not like 
	to_char(longtodate(j.creation_time),'YYYY-MM-dd') 
and stl.stateid = 4
and (
     (stl.entry_start_time between stl2.ENTRY_START_TIME and stl2.ENTRY_END_TIME) 
     or 
	(stl2.ENTRY_END_TIME is null and stl2.ENTRY_START_TIME < stl.ENTRY_START_TIME)
     )