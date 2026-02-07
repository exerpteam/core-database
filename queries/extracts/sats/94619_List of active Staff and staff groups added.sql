select distinct
--e.center ||'emp'|| e.id as "employee ID",
p.center ||'p'|| p.id as "Member ID",
p.fullname,
ext.txtvalue as "Staff external ID",
pr.name as "subscription"

from persons p

join subscriptions s
on
s.owner_center = p.center
and
s.owner_id = p.id

        JOIN
            subscriptiontypes st
        ON
            st.center = s.subscriptiontype_center
        AND st.id = s.subscriptiontype_id
        JOIN
            products pr
        ON
            pr.center = st.center
        AND pr.id = st.id


join employees e
on
e.personcenter = p.center
and
e.personid = p.id
AND e.blocked = false

join person_staff_groups psg
on
psg.person_center = p.center
and psg.person_id = p.id

left join person_ext_attrs ext
on
ext.personcenter = p.center
and
ext.personid = p.id
and
 ext.name = '_eClub_StaffExternalId'

where
p.persontype = 2
and p.center in (:scope)
and s.state IN (2,4)