Select distinct
je.id,
longtodate(je.creation_time),
s.owner_center||'p'|| s.owner_id as memberid



from subscriptions s

join subscriptiontypes st
on
s.subscriptiontype_center = st.center
and
s.subscriptiontype_id = st.id
and st.rec_clipcard_product_center is null

join persons p
on
p.center = s.owner_center
and
p.id = s.owner_id

join journalentries je
on
je.person_center = s.owner_center
and 
je.person_id = s.owner_id
and
je.jetype = 1
and
TO_CHAR(longtodate(je.creation_time), 'YYYY-MM-DD HH24:MI') = TO_CHAR(longtodate(s.creation_time), 'YYYY-MM-DD HH24:MI')



where 
s.state in (2,4)
and p.external_id = (:externalid)