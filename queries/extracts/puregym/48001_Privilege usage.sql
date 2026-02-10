-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-4305
https://clublead.atlassian.net/browse/ST-4810
 SELECT
     p.EXTERNAL_ID "External ID",
     c.SHORTNAME "Center",
     p.Center||'p'||p.id "P Number",
     pr.NAME "Subscription",
     TO_CHAR(s.START_DATE,'DD/MM/YYYY') "Subscription Start",
     CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END AS "Subscription State",
     mpr.CACHED_PRODUCTNAME                                                   "Source",
     sp.Name                                                                  "Target",
     TO_CHAR(longtodateC(pu.USE_TIME, pu.TARGET_CENTER),'DD/MM/YYYY HH24:MI') "Starttime",
     CASE pea_email.TXTVALUE WHEN 'true' THEN 'Yes' ELSE 'No' END "Email Opt In",
     cou.SHORTNAME AS "Center of Usage"
 FROM
     PRIVILEGE_USAGES pu
 JOIN
     PRIVILEGE_GRANTS pg
 ON
     pg.ID = pu.GRANT_ID
     AND pg.GRANTER_SERVICE = 'Addon'
 JOIN
     PERSONS p
 ON
     p.CENTER = pu.PERSON_CENTER
     AND p.ID = pu.PERSON_ID
 JOIN
     SUBSCRIPTION_ADDON sa
 ON
     sa.ID = pu.SOURCE_ID
 JOIN
     SUBSCRIPTIONS s
 ON
     s.CENTER = sa.SUBSCRIPTION_CENTER
     AND s.ID = sa.SUBSCRIPTION_ID
 JOIN
     PRODUCTS pr
 ON
     s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
     AND s.SUBSCRIPTIONTYPE_ID = pr.ID
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
 JOIN
     CENTERS cou
 ON
     cou.ID = pu.TARGET_CENTER
 JOIN
     INVOICE_LINES_MT il
 ON
     il.CENTER = pu.TARGET_CENTER
     AND il.ID = pu.TARGET_ID
     AND il.SUBID = pu.TARGET_SUBID
 JOIN
     PRODUCTS sp
 ON
     il.PRODUCTCENTER = sp.CENTER
     AND il.PRODUCTID = sp.ID
 JOIN
     MASTERPRODUCTREGISTER mpr
 ON
     mpr.ID = sa.ADDON_PRODUCT_ID
 LEFT JOIN
     PERSON_EXT_ATTRS pea_email
 ON
     pea_email.NAME = 'eClubIsAcceptingEmailNewsLetters'
     AND pea_email.PERSONCENTER = p.CENTER
     AND pea_email.PERSONID = p.ID
 WHERE
     pu.TARGET_SERVICE IN ('InvoiceLine')
     AND pu.STATE = 'USED'
     AND pu.TARGET_CENTER IN ($$Center$$)
     AND pu.USE_TIME >= :From_Date
     AND pu.USE_TIME < :To_Date+24*3600*1000
 UNION ALL
 SELECT
     p.EXTERNAL_ID "External ID",
     c.SHORTNAME "Center",
     p.Center||'p'||p.id "P Number",
     pr.NAME "Subscription",
     TO_CHAR(s.START_DATE,'DD/MM/YYYY') "Subscription Start",
     CASE  s.state  WHEN 2 THEN 'Active'  WHEN 3 THEN 'Ended'  WHEN 4 THEN 'Frozen'  WHEN 7 THEN 'Window'  WHEN 8 THEN 'Created' ELSE 'Unknown' END AS "Subscription State",
     pr.Name                                                                  "Source",
     sp.Name                                                                  "Target",
     TO_CHAR(longtodateC(pu.USE_TIME, pu.TARGET_CENTER),'DD/MM/YYYY HH24:MI') "Starttime",
     CASE pea_email.TXTVALUE WHEN 'true' THEN 'Yes' ELSE 'No' END "Email Opt In",
     cou.SHORTNAME AS "Center of Usage"
 FROM
     PRIVILEGE_USAGES pu
 JOIN
     PRIVILEGE_GRANTS pg
 ON
     pg.ID = pu.GRANT_ID
     AND pg.GRANTER_SERVICE = 'GlobalSubscription'
 JOIN
     SUBSCRIPTIONS s
 ON
     pu.SOURCE_CENTER = s.CENTER
     AND pu.SOURCE_ID = s.ID
 JOIN
     PERSONS p
 ON
     p.CENTER = s.owner_center
     AND p.ID = s.owner_id
 JOIN
     PRODUCTS pr
 ON
     s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
     AND s.SUBSCRIPTIONTYPE_ID = pr.ID
 JOIN
     CENTERS c
 ON
     c.ID = p.CENTER
 JOIN
     CENTERS cou
 ON
     cou.ID = pu.TARGET_CENTER
 JOIN
     INVOICE_LINES_MT il
 ON
     il.CENTER = pu.TARGET_CENTER
     AND il.ID = pu.TARGET_ID
     AND il.SUBID = pu.TARGET_SUBID
 JOIN
     PRODUCTS sp
 ON
     il.PRODUCTCENTER = sp.CENTER
     AND il.PRODUCTID = sp.ID
 LEFT JOIN
     PERSON_EXT_ATTRS pea_email
 ON
     pea_email.NAME = 'eClubIsAcceptingEmailNewsLetters'
     AND pea_email.PERSONCENTER = p.CENTER
     AND pea_email.PERSONID = p.ID
 WHERE
     pu.PRIVILEGE_TYPE = 'PRODUCT'
     AND pu.STATE = 'USED'
     AND pu.TARGET_CENTER IN ($$Center$$)
     AND pu.USE_TIME >= :From_Date
     AND pu.USE_TIME < :To_Date+24*3600*1000
