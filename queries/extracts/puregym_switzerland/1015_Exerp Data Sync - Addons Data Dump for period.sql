-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
     cp.EXTERNAL_ID AS "EXTERNALID",
     prod_addon.CENTER||'prod'||prod_addon.ID "PRODUCTID",
     prod_addon.NAME                       AS "NAME",
     TO_CHAR(sa.START_DATE,'DD/MM/YYYY')   AS "STARTDATE",
     TO_CHAR(sa.END_DATE,'DD/MM/YYYY')   AS "ENDDATE",
     COALESCE(round(sa.INDIVIDUAL_PRICE_PER_UNIT,2)*sa.QUANTITY, 0) AS "PRICE",
     s.CENTER||'ss'||s.ID                     AS "SUBSCRIPTIONID",
     TO_CHAR(longtodateC(s.CREATION_TIME,s.CENTER),'DD/MM/YYYY HH24:MI:SS')  AS "CREATIONTIME",
     TO_CHAR(longtodateC(sa.LAST_MODIFIED,s.CENTER),'DD/MM/YYYY HH24:MI:SS') AS "LASTMODIFIEDDATE"
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
     PERSONS cp
 ON
     cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
 AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
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
 WHERE
     cp.CENTER IN ($$Scope$$)
     AND sa.CANCELLED = 0
     AND sa.LAST_MODIFIED >= $$fromdate$$
   AND sa.LAST_MODIFIED < $$todate$$ + (86400 * 1000)