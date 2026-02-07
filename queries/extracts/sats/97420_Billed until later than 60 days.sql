WITH params AS MATERIALIZED
(
         SELECT
                TO_DATE(getCenterTime(c.id),'YYYY-MM-DD') + INTERVAL '60 days' AS cutdate,
                c.id
         FROM centers c
         WHERE
                c.id IN (:Scope)
)


select
s.center ||'ss'|| s.id as subscriptionID,
s.billed_until_date

from subscriptions s

JOIN params ON
        s.center = params.id 

join subscriptiontypes st
on
s.subscriptiontype_center = st.center
and
s.subscriptiontype_id = st.id

where
s.billed_until_date > cutdate
and st.st_type = 1
and s.state in (2,4,8)