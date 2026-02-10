-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
c.name,
staff.fullname as STAFF_FULLNAME,
ag.name, a.name,
    per.fullname AS MEMBER_FULLNAME,
    s.owner_center||'p'||s.owner_id AS memberid,
    s.center ||'ss'||s.id           AS subscriptionid, p.name as PRODUCT_NAME
, longtodateC(b.starttime,b.center) as booking_start, longtodateC(b.stoptime,b.center) as booking_stop
FROM
    subscriptions s
LEFT JOIN
    recurring_participations rp
ON
    s.center = rp.subscription_center
AND s.id = rp.subscription_id
JOIN
    subscriptiontypes st
ON
    s.subscriptiontype_center = st.center
AND s.subscriptiontype_id = st.id
JOIN
    products p
ON
    p.center = st.center
AND p.id = st.id
LEFT JOIN
    privilege_usages pu
ON
    s.center = pu.source_center
AND s.id = pu.source_id
LEFT JOIN
    participations pa
ON
    pa.center = pu.target_center
AND pa.id = pu.target_id
LEFT JOIN
    bookings b
ON
    pa.booking_center = b.center
AND pa.booking_id = b.id
LEFT JOIN
    activity a
ON
    b.activity = a.id
    left join lifetime.activity_group ag on ag.id = a.activity_group_id
    left join lifetime.staff_usage su on su.booking_center = b.center and su.booking_id = b.id
    left join persons staff on staff.center = su.person_center and staff.id = su.person_id
    left join persons per on per.center = s.owner_center and per.id = s.owner_id
	left join centers c on c.id = b.center
WHERE
    rp.course_id IS NULL
AND b.course_id IS NOT NULL
AND s.state= 2
AND s.sub_state =1
AND st.st_type = 3
AND pu.state !='CANCELLED'
AND s.end_date IS NULL
AND longtodateC(b.starttime,b.center) >now()
--GROUP BY c.name,per.fullname,memberid,subscriptionid,ag.name, staff.fullname,a.name, p.name
ORDER BY c.name ASC,staff.fullname ASC, PER.FULLNAME ASC