-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-1920
SELECT DISTINCT
    referrer.center||'p'||referrer.id                             AS referrer_id,
    pr_referrer.name                                              AS referrer_membership,
    referred.center||'p'||referred.id                             AS referred_id,
    pr_referred.name                                              AS referred_membership,
    s_referred.start_date                                         AS referred_subscription_start,
    TO_CHAR(s_referred.start_date+INTERVAL'45 DAYS','yyyy-mm-dd') AS "45th_Day"
FROM
    chelseapiers.relatives rel
JOIN
    chelseapiers.persons referrer
ON
    rel.relativecenter = referrer.center
AND rel.relativeid = referrer.id
JOIN
    chelseapiers.subscriptions s_referrer
ON
    s_referrer.owner_center = referrer.center
AND s_referrer.owner_id = referrer.id
AND s_referrer.state IN (2)
JOIN
    chelseapiers.subscriptiontypes st_referrer
ON
    st_referrer.center = s_referrer.subscriptiontype_center
AND st_referrer.id = s_referrer.subscriptiontype_id
JOIN
    chelseapiers.products pr_referrer
ON
    pr_referrer.center = st_referrer.center
AND pr_referrer.id = st_referrer.id
JOIN
    chelseapiers.persons referred
ON
    referred.center = rel.center
AND referred.id = rel.id
JOIN
    chelseapiers.product_and_product_group_link ppgl_referrer
ON
    ppgl_referrer.product_center = pr_referrer.center
AND ppgl_referrer.product_id = pr_referrer.id
JOIN
    chelseapiers.product_group pg_referrer
ON
    pg_referrer.id = ppgl_referrer.product_group_id
      and pg_referrer.name IN ('Membership','TFC Membership')
LEFT JOIN
    chelseapiers.subscriptions s_referred
ON
    s_referred.owner_center = referred.center
AND s_referred.owner_id = referred.id
AND s_referred.state IN (2)
LEFT JOIN
    chelseapiers.subscription_sales ss
ON
    ss.subscription_center = s_referred.center
AND ss.subscription_id = s_referred.id
LEFT JOIN
    chelseapiers.subscriptiontypes st_referred
ON
    st_referred.center = s_referred.subscriptiontype_center
AND st_referred.id = s_referred.subscriptiontype_id
LEFT JOIN
    products pr_referred
ON
    pr_referred.center = st_referred.center
AND pr_referred.id = st_referred.id
LEFT JOIN
    chelseapiers.product_and_product_group_link ppgl_referred
ON
    ppgl_referred.product_center = pr_referred.center
AND ppgl_referred.product_id = pr_referred.id
LEFT JOIN
    chelseapiers.product_group pg_referred
ON
    pg_referred.id = ppgl_referred.product_group_id
WHERE
    rel.rtype = 13
AND rel.status = 1
and pg_referred.name IN ('TFC Membership','Membership')
and TO_CHAR(s_referred.start_date+INTERVAL'45 DAYS','yyyy-mm-dd') BETWEEN :45th_day_start AND :45th_day_end
AND pg_referrer.name||' '||pg_referred.name NOT IN ('TFC Membership TFC Membership')
AND pg_referrer.name||' '||pg_referred.name NOT IN ('Membership TFC Membership')