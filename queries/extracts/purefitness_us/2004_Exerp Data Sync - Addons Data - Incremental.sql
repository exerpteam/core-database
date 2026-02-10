-- The extract is extracted from Exerp on 2026-02-08
--  
 WITH
    PARAMS AS materialized
    (
         SELECT
             id   AS  center,
			CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')-interval '3' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS FROMDATE,
			CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')+interval '1' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS TODATE,
             'yyyy-MM-dd HH24:MI:SS' DATETIMEFORMAT,
             time_zone  AS       TZFORMAT
         FROM 
             centers 
    )
 SELECT
     distinct
     cp.EXTERNAL_ID AS "EXTERNALID",
     prod_addon.CENTER||'prod'||prod_addon.ID "PRODUCTID",
     prod_addon.NAME                       AS "NAME",
     TO_CHAR(sa.START_DATE,'DD/MM/YYYY')   AS "STARTDATE",
     TO_CHAR(sa.END_DATE,'DD/MM/YYYY')   AS "ENDDATE",
     COALESCE(round(sa.INDIVIDUAL_PRICE_PER_UNIT,2)*sa.QUANTITY, 0) AS "PRICE",
     s.CENTER||'ss'||s.ID                     AS "SUBSCRIPTIONID",
     TO_CHAR(longtodateC(s.creation_time,s.CENTER),DATETIMEFORMAT) AS "CREATIONTIME",
     TO_CHAR(longtodateC(sa.LAST_MODIFIED,s.CENTER),DATETIMEFORMAT) AS "LASTMODIFIEDDATE"
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
    PARAMS
ON
    params.center = sa.center_id    
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
     sa.CENTER_ID IN ($$Scope$$)
     AND sa.CANCELLED = false
     AND sa.LAST_MODIFIED >= PARAMS.FROMDATE
     AND sa.LAST_MODIFIED < PARAMS.TODATE
UNION ALL
     SELECT 
        NULL AS "EXTERNALID",
        NULL AS "PRODUCTID",
        NULL AS "NAME",
        NULL AS "STARTDATE",
        NULL AS "ENDDATE",
        NULL AS "PRICE",
        NULL AS "SUBSCRIPTIONID",
        NULL AS "CREATEDDATE",
        NULL AS "LASTMODIFIEDDATE"    
