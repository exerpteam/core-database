-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    biview.*
FROM
   (SELECT DISTINCT
    CAST ( pu.ID AS VARCHAR(255)) "PRODUCT_PRIVILEGE_USAGE_ID",
    CASE
        WHEN pg.GRANTER_SERVICE = 'GlobalCard'
        THEN 'CLIPCARD'
        WHEN pg.GRANTER_SERVICE = 'GlobalSubscription'
        THEN 'SUBSCRIPTION'
        WHEN pg.GRANTER_SERVICE = 'Addon'
        THEN 'SUBSCRIPTION_ADDON'
        WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND rg.RGTYPE ='CAMPAIGN'
        THEN 'CAMPAIGN'
        WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND rg.RGTYPE ='UNLIMITED'
        THEN 'TARGET_GROUP'
        WHEN pg.GRANTER_SERVICE = 'StartupCampaign'
        THEN 'STARTUP_CAMPAIGN'
        WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
        THEN 'COMPANY_AGREEMENT'
        WHEN pg.GRANTER_SERVICE = 'Access product'
        THEN 'ACCESS_PRODUCT'
        ELSE 'UNDEFINED'
    END "SOURCE_TYPE",
    CASE
        WHEN pg.GRANTER_SERVICE = 'GlobalCard'
        THEN pu.SOURCE_CENTER || 'cc' || pu.SOURCE_ID ||'id'|| pu.SOURCE_SUBID
        WHEN pg.GRANTER_SERVICE = 'GlobalSubscription'
        THEN pu.SOURCE_CENTER || 'ss' || pu.SOURCE_ID
        WHEN pg.GRANTER_SERVICE = 'Addon'
        THEN '' || pu.SOURCE_ID
        WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND rg.RGTYPE ='CAMPAIGN'
        THEN 'C_' || pu.SOURCE_ID
        WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND rg.RGTYPE ='UNLIMITED'
        THEN 'TG_' || pu.SOURCE_ID
        WHEN pg.GRANTER_SERVICE = 'StartupCampaign'
        THEN 'SC_' || pg.GRANTER_ID
        WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
        THEN pg.GRANTER_CENTER || 'p' || pg.GRANTER_ID || 'rpt' || pg.GRANTER_SUBID
        WHEN pg.GRANTER_SERVICE = 'Access product'
        THEN pu.SOURCE_CENTER || 'inv' || pu.SOURCE_ID ||'ln'|| pu.SOURCE_SUBID
        ELSE 'N/A'
    END "SOURCE_ID",
    CASE
        WHEN pu.TARGET_SERVICE = 'InvoiceLine'
        THEN 'SALES_LOG'
        WHEN pu.TARGET_SERVICE = 'SubscriptionPrice'
        THEN 'SUBSCRIPTION_PRICE'
        ELSE NULL
    END "TARGET_TYPE",
    CASE
        WHEN pu.TARGET_SERVICE = 'InvoiceLine'
        THEN pu.TARGET_CENTER || 'inv' || pu.TARGET_ID || 'ln' || pu.TARGET_SUBID
        WHEN pu.TARGET_SERVICE = 'SubscriptionPrice'
        THEN '' || pu.TARGET_ID
        ELSE NULL
    END         "TARGET_ID",
    pu.STATE AS "STATE",
    cc.CODE  AS "CAMPAIGN_CODE",
    CASE
        WHEN pu.TARGET_SERVICE = 'InvoiceLine'
        THEN pu.TARGET_CENTER
        WHEN pu.TARGET_SERVICE = 'SubscriptionPrice'
        THEN sp.SUBSCRIPTION_CENTER
        ELSE NULL
    END                 "CENTER_ID",
    COALESCE(pu.last_modified,pu.USE_TIME,pu.PLAN_TIME) AS "ETS"
FROM
    PRIVILEGE_USAGES pu
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
LEFT JOIN
    PRIVILEGE_RECEIVER_GROUPS rg
ON
    pg.GRANTER_SERVICE = 'ReceiverGroup'
    AND rg.ID = pu.SOURCE_ID
LEFT JOIN
    CAMPAIGN_CODES cc
ON
    cc.id = pu.CAMPAIGN_CODE_ID
LEFT JOIN
    SUBSCRIPTION_PRICE sp
ON
    pu.TARGET_SERVICE = 'SubscriptionPrice'
    AND sp.ID = pu.TARGET_ID
WHERE
    pu.TARGET_SERVICE IN ('InvoiceLine',
                          'SubscriptionPrice')) biview
WHERE
    biview."ETS" BETWEEN (($$from_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000 AND ((
            $$to_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000