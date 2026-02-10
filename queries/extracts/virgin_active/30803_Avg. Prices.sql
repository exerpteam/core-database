-- The extract is extracted from Exerp on 2026-02-08
-- COLONNE: Club + Sub Type + Price Signed on Contact (€) + Member ID + Price from Pricelist
https://clublead.atlassian.net/browse/ST-2611
 SELECT
    c.SHORTNAME AS "Club",
    pr.NAME AS "Sub Type",
    pr.PRICE AS "Price Signed on Contact (\342\202\254)",
    p.CENTER||'p'||p.ID AS "Member ID",
    spp.SUBSCRIPTION_PRICE "Price from Pricelist"
 FROM
    persons p
 JOIN
    SUBSCRIPTIONS s
 ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
 JOIN
    PRODUCTS pr
 ON
    s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = pr.ID
 JOIN
    SUBSCRIPTIONPERIODPARTS spp
 ON
    spp.CENTER = s.CENTER
    AND spp.ID = s.ID
 JOIN
    centers c
 ON
    c.ID = p.CENTER
    AND spp.FROM_DATE BETWEEN ($$START_DATE$$) AND ($$END_DATE$$)
    AND c.ID in ($$SCOPE$$)
