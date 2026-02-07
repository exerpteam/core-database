select 
p.firstname,
p.lastname,
p.center ||'p'||p.id as personid,
sg.name as staff_group,
sg.default_salary as salary
from stjames.persons p
join stjames.person_staff_groups psg
on psg.person_center = p.center
and psg.person_id = p.id
join stjames.staff_groups sg
on psg.staff_group_id = sg.id