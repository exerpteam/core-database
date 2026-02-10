-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-2081
 SELECT
     s.owner_center || 'p' || s.owner_id               AS PersonId,
     subprod.name                                      AS "Subscription Name",
     s.start_date                                      AS "Subscription Start Date",
     s.end_date                                        AS "Subscription End Date",
     addon_pr.name                                     AS "Add-on Name",
     sa.start_date                                     AS "Add-on Start Date",
     sa.end_date                                       AS "Add-on End Date",
     COALESCE(sa.individual_price_per_unit, addon_pr.PRICE) AS "Add-on Price"
 FROM
     subscription_addon sa
 JOIN
     subscriptions s
 ON
     sa.subscription_center = s.center
     AND sa.subscription_id = s.id
 JOIN
     subscriptiontypes st
 ON
     st.center = s.subscriptiontype_center
     AND st.id = s.subscriptiontype_id
     AND st.st_type = 0
 JOIN
     products subprod
 ON
     subprod.center = st.center
     AND subprod.id = st.id
 JOIN
     MASTERPRODUCTREGISTER m
 ON
     sa.ADDON_PRODUCT_ID=m.ID
 JOIN
     PRODUCTS addon_pr
 ON
     addon_pr.GLOBALID = m.GLOBALID
     AND addon_pr.center = sa.CENTER_ID
     AND COALESCE(sa.individual_price_per_unit, addon_pr.PRICE) > 0
 WHERE
     s.owner_center IN ($$Scope$$)
     AND sa.start_date >= $$StartDate$$
     AND sa.end_date <= $$EndDate$$
     AND sa.cancelled = 0
     AND sa.start_date > s.start_date
     AND EXISTS
     (
         SELECT
             1
         FROM
             subscription_reduced_period srp
         WHERE
             srp.subscription_center = s.center
             AND srp.subscription_id = s.id
             AND srp.state = 'ACTIVE'
             AND sa.start_date BETWEEN srp.start_date AND srp.end_date)
