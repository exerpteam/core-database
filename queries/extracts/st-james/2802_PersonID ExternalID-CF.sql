select 
	p.id,
	p.home_center_id,
	p.home_center_person_id,
	p.home_center_id || 'p' || p.home_center_person_id as member_id,
	p.staff_external_id,
	pd.person_id,
	pd.email,
	pd.full_name 
from stjames.person_detail pd 
left join
	stjames.person p on p.id = pd.person_id;