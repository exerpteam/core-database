 select distinct
 p.center ||'p'|| p.id as "Member ID",
 p.external_id as "External ID",
 c.country as "Country",
 CASE P.persontype WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person type",
 pr.name as "Subscription Name"
 from persons p
 join centers c
 on
 p.center = c.id
 join subscriptions s
 on s.owner_center = p.center
 and
 s.owner_id = p.id
 and s.state in (2,4,8)
 JOIN
     SubscriptionTypes st
 ON
     s.SubscriptionType_Center = st.Center
 AND s.SubscriptionType_ID = st.ID
 JOIN
     Products pr
 ON
     st.Center = pr.Center
 AND st.Id = pr.Id
 where
 p.status in (1,3)
 and p.center in (:scope)
 AND NOT EXISTS
     (
         SELECT
             *
 from
 clipcards cl2
 join products pr2
 on
 pr2.center = cl2.center
 AND pr2.id = cl2.id
 where
    cl2.OWNER_CENTER = p.center
 and
 cl2.OWNER_ID = p.id
 and (cl2.finished = 0 and pr2.GLOBALID = 'PTSTARTNEW')
     )
