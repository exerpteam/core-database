-- The extract is extracted from Exerp on 2026-02-08
--  
select 	s.ID,
		s.OWNER_CENTER,
		s.OWNER_ID,
		s.STATE,
		s.SUB_STATE,
		s.CENTER,
		s.START_DATE,
		s.END_DATE,
		s.FAMILY_ID,
		s.BILLED_UNTIL_DATE,
		p.EXTERNAL_ID
from SUBSCRIPTIONS s
join PERSONS p
	on p.CENTER = s.OWNER_CENTER
	and p.ID = s.OWNER_ID
where p.EXTERNAL_ID = '638939'