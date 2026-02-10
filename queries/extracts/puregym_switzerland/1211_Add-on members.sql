-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/EC-7538
SELECT
     s.CENTER||'ss'||s.ID AS "SUBSCRIPTION_ID",
     p.EXTERNAL_ID AS "EXTERNAL_ID",
     b.EXTERNAL_ID  AS "BUDDY_EXTERNAL_ID" ,
     p.CENTER||'p'||p.ID AS "PERSON_ID",
     c.NAME AS "CENTER_NAME",
     c.ID AS "CENTER_ID",
     s.SUBSCRIPTION_PRICE AS "SUBSCRIPTION_PRICE",
     TO_CHAR(s.START_DATE,'yyyy-MM-dd') AS "START_DATE",
     TO_CHAR(s.END_DATE,'yyyy-MM-dd') AS "END_DATE",
     TO_CHAR(longtodateC(s.CREATION_TIME,p.CENTER),'yyyy-MM-dd hh24:mm') AS "SUBS_DATETIME",
     TO_CHAR(longtodateC(sa.CREATION_TIME,p.CENTER),'yyyy-MM-dd hh24:mm') AS "ADDON_DATETIME",
     prod.GLOBALID AS "SUBS_GLOBAL_ID",
     prod_addon.NAME AS "ADDON_NAME",
     sa.INDIVIDUAL_PRICE_PER_UNIT  AS "ADDON_PRICE_PER_UNIT",
     sa.QUANTITY AS "ADDON_QUANTITY",
     TO_CHAR(sa.START_DATE,'yyyy-MM-dd')  AS "ADDON_START_DATE",
     TO_CHAR(COALESCE(sa.END_DATE,longtodateC(sa.ENDING_TIME,p.CENTER)),'yyyy-MM-dd') AS "ADDON_END_OR_CANCEL_DATE"
 FROM
     SUBSCRIPTION_ADDON sa
 JOIN
     SUBSCRIPTIONS s
 ON
     s.center = sa.SUBSCRIPTION_CENTER
     AND s.id = sa.SUBSCRIPTION_ID
 JOIN
     PERSONS p
 ON
     p.center = s.OWNER_CENTER
     AND p.id = s.OWNER_ID
 LEFT JOIN
     RELATIVES r
 ON
     p.CENTER = r.CENTER
     AND p.ID = r.ID
     AND r.rtype = 5
     AND r.status = 1
 LEFT JOIN
     PERSONS b
 ON
     r.RELATIVEID = b.ID
     AND r.RELATIVECENTER = b.CENTER
 JOIN
     MASTERPRODUCTREGISTER mpr_addon
 ON
     mpr_addon.id = sa.ADDON_PRODUCT_ID
 JOIN
     PRODUCTS prod_addon
 ON
     prod_addon.center = sa.CENTER_ID
     AND prod_addon.GLOBALID = mpr_addon.GLOBALID
 JOIN
    PRODUCTS prod
 ON
    s.SUBSCRIPTIONTYPE_CENTER = prod.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = prod.ID
 JOIN
    CENTERS c
 ON
     c.ID = p.CENTER
 WHERE
    sa.START_DATE <= (:AddonStartDate)
    AND p.CENTER in (:Scope)
    AND s.STATE in (:SubscriptionState)
