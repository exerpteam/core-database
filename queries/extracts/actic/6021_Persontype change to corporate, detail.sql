select 
    stl.center||'p'||stl.id as person,
    longtodate(stl.entry_start_time) as change_time,
    p.status
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
    and j.jetype = 3 and j.person_subid = 1 /*person creation message*/
where
    stl.entry_type = 3 /*person type log*/
and p.center in (:scope)
and stl.entry_start_time between (:from_date) and (:to_date)
and p.status in (:person_status)
and s.state in (:subscription_state)
and longtodate(stl.entry_start_time) <> longtodate(j.creation_time) 
/*to prevent thoes that start of as corporate to be included*/
and stl.stateid = 4 /*corporate*/

