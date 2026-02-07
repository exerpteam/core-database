Select
s.owner_center ||'p'|| s.owner_id as "MemberID",
	CASE  s.STATE  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW'  WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS "SubcriptionState",
ext.txtvalue as "AMFPRICE"

from person_ext_attrs ext

join subscriptions s
on
s.owner_center = ext.personcenter
and
s.owner_id  = ext.personid
and ext.name = 'AMFPRICE'

where
s.owner_center in (:scope)
and
s.state in (:subscription_state)
and ext.txtvalue is not null