-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
DECODE($$offset$$,-1,0,(TRUNC(exerpsysdate())-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
(TRUNC(exerpsysdate()+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000 AS TODATE
FROM
dual

    )
-- Startup campaign
SELECT
    cp.external_id,
    cp.CENTER||'p'|| cp.ID                                                        AS MemberID,
    'Startup Campaign'                                                          AS SourceType,
    sc.NAME                                                                     AS CampaignName,
    ps.NAME                                                                     AS privilegeSetName,
    TO_CHAR(longtodatec(sc.starttime, s.owner_center), 'DD-MM-YYYY')            AS ValidFrom,
    TO_CHAR(longtodatec(sc.endtime, s.owner_center), 'DD-MM-YYYY')                                            AS ValidTo,
       CASE
         WHEN pp.price_modification_name IN ('FIXED_REBATE', 'OVERRIDE') THEN
              'Fixed price of ' || pp.price_modification_amount
         ELSE
              'Rebate of ' || pp.price_modification_amount*100 || '%'                     
       END AS Price,
    TO_CHAR(longtodateC(s.CREATION_TIME, s.owner_center), 'DD-MM-YYYY HH24:MI') AS SubscriptionCreationDate,
'Subscription' AS Type,
prod.PRICE AS ProductPrice,
CASE
         WHEN pp.price_modification_name IN ('FIXED_REBATE', 'OVERRIDE') THEN
              pp.price_modification_amount
         ELSE
             (1 - pp.price_modification_amount) * prod.PRICE                    
       END AS CampaignPrice
FROM params,
	 SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.center = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
JOIN PERSONS cp 
ON
   cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID  
 JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND 
sp.SUBSCRIPTION_ID = s.id
    AND sp.CANCELLED = 0
 JOIN
    PRIVILEGE_USAGES pu
ON
    sp.ID = pu.TARGET_ID
    AND pu.TARGET_SERVICE = 'SubscriptionPrice'
  JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
    AND pg.GRANTER_SERVICE IN ('StartupCampaign')
  JOIN
    STARTUP_CAMPAIGN sc
ON
    sc.ID = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE='StartupCampaign'
 JOIN
   PRODUCTS prod
ON
    prod.CENTER = s.subscriptiontype_center
    AND prod.ID = s.subscriptiontype_id
 JOIN
    PRIVILEGE_SETS ps
ON
    ps.ID = pg.PRIVILEGE_SET
  JOIN
    product_privileges pp
ON
    pp.privilege_set = ps.id
    AND (pp.ref_globalid = prod.globalid OR pp.ref_globalid IS NULL)
    AND pp.price_modification_name IN ('FIXED_REBATE', 'OVERRIDE', 'PERCENTAGE_REBATE')
       AND pp.valid_to IS NULL
	and pp.price_modification_amount IS NOT NULL
WHERE
    s.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
AND s.SUB_STATE <> 8