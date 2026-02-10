-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
  params AS materialized
     (
        SELECT
         id   AS  center,
         CAST(datetolongC(TO_CHAR(CAST($$fromdate$$ AS DATE), 'YYYY-MM-DD HH24:MI'), id) AS BIGINT) AS FROMDATE,
         CAST(datetolongC(TO_CHAR(CAST($$todate$$ AS DATE)+1, 'YYYY-MM-DD HH24:MI'), id)  AS BIGINT) AS TODATE,
         'YYYY-MM-dd HH24:MI:SS' DATETIMEFORMAT,
         time_zone  AS       TZFORMAT
        FROM 
         centers c
)
SELECT
    cp.EXTERNAL_ID AS "EXTERNALID",
    prod_addon.CENTER||'prod'||prod_addon.ID "PRODUCTID",
    prod_addon.NAME                       AS "NAME",
    TO_CHAR(sa.START_DATE,'DD/MM/YYYY')   AS "STARTDATE",
    TO_CHAR(sa.END_DATE,'DD/MM/YYYY')   AS "ENDDATE",
    sa.INDIVIDUAL_PRICE_PER_UNIT*sa.QUANTITY AS "PRICE",
    s.CENTER||'ss'||s.ID                     AS "SUBSCRIPTIONID",
    TO_CHAR(longtodateC(s.CREATION_TIME,s.CENTER),params.DATETIMEFORMAT)  AS "CREATIONTIME",
    TO_CHAR(longtodateC(sa.LAST_MODIFIED,s.CENTER),params.DATETIMEFORMAT) AS "LASTMODIFIEDDATE"
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
JOIN
   PARAMS
ON
   params.center = sa.center_id   
WHERE
   sa.center_id in ($$Scope$$)
   AND sa.CANCELLED = false
   AND sa.LAST_MODIFIED >= params.FROMDATE
   AND sa.LAST_MODIFIED < params.TODATE


