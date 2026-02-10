-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.fullname as "Member Name",
    p.external_id "Member External_ID",
    sub.center||'ss'||sub.id as "Subscription ID",
    pd.name as "Product Name",
    tr.fullname as "Selling Employee",
    tr.external_id as "Selling Employee External_ID",
    sub.start_date,
    sub.end_date
FROM
    lifetime.subscriptions sub
JOIN
    products pd
ON
    pd.center = sub.subscriptiontype_center
AND pd.id = sub.subscriptiontype_id
JOIN
    lifetime.subscriptiontypes st
ON
    st.center = pd.center
AND st.id = pd.id
AND st.st_type=3
JOIN
    lifetime.persons p
ON
    p.center = sub.owner_center
AND p.id = sub.owner_id
JOIN
   lifetime.persons tr
ON
   tr.center = sub.creator_center and 
  tr.id = sub.creator_id 
LEFT JOIN
    lifetime.recurring_participations rp
ON
    rp.subscription_center = sub.center
AND rp.subscription_id = sub.id
AND rp.subscription_center IN (:Scope)
where sub.state = 2
and rp.course_id is null
GROUP BY
   p.fullname,
    p.external_id,
    sub.center||'ss'||sub.id,
    pd.name,
    rp.course_id,rp.start_time, rp.end_time,
tr.fullname,
    tr.external_id,
 sub.start_date,
    sub.end_date,sub.creator_center,
    sub.creator_id
