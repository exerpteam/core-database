-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$
                WHEN -1
                THEN 0
                ELSE (TRUNC(CURRENT_TIMESTAMP)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*
                    3600*1000::bigint
            END                                                                         AS FROMDATE,
            (TRUNC(CURRENT_TIMESTAMP+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint AS
            TODATE
    )
SELECT
   CAST ( pu.ID AS VARCHAR(255)) AS "ACCESS_PRIVILEGE_USAGE_ID",
    CASE
        WHEN pg.GRANTER_SERVICE = 'GlobalCard'
        THEN 'CLIPCARD'
        WHEN pg.GRANTER_SERVICE = 'GlobalSubscription'
        THEN 'SUBSCRIPTION'
        WHEN pg.GRANTER_SERVICE = 'Access product'
        THEN 'ACCESS_PRODUCT'
        WHEN pg.GRANTER_SERVICE = 'Addon'
        THEN 'SUBSCRIPTION_ADDON'
        WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
        THEN 'COMPANY_AGREEMENT'
        WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
        THEN 'TARGET_GROUP'
        WHEN pg.GRANTER_SERVICE = 'StartupCampaign'
        THEN 'CAMPAIGN'
        ELSE 'UNDEFINED'
    END "SOURCE_TYPE",
    CASE
        WHEN pg.GRANTER_SERVICE = 'GlobalCard'
        THEN pu.SOURCE_CENTER || 'cc' || pu.SOURCE_ID ||'id'|| pu.SOURCE_SUBID
        WHEN pg.GRANTER_SERVICE = 'GlobalSubscription'
        THEN pu.SOURCE_CENTER || 'ss' || pu.SOURCE_ID
        WHEN pg.GRANTER_SERVICE = 'Access product'
        THEN pu.SOURCE_CENTER || 'inv' || pu.SOURCE_ID ||'ln'|| pu.SOURCE_SUBID
        WHEN pg.GRANTER_SERVICE = 'Addon'
        THEN '' || pu.SOURCE_ID
        ELSE 'N/A'
    END "SOURCE_ID",
    CASE
        WHEN pu.TARGET_SERVICE = 'Participation'
        THEN 'PARTICIPATION'
        WHEN pu.TARGET_SERVICE = 'Attend'
        THEN 'ATTEND'
        WHEN pu.TARGET_SERVICE = 'Booking'
        THEN 'BOOKING'
        ELSE NULL
    END "TARGET_TYPE",
    CASE
        WHEN pu.TARGET_SERVICE = 'Participation'
        THEN pu.TARGET_CENTER || 'par' || pu.TARGET_ID
        WHEN pu.TARGET_SERVICE = 'Attend'
        THEN pu.TARGET_CENTER || 'att' || pu.TARGET_ID
        WHEN pu.TARGET_SERVICE = 'Booking'
        THEN pu.TARGET_CENTER || 'bk' || pu.TARGET_ID
        ELSE NULL
    END         "TARGET_ID",
    pu.STATE          AS "STATE",
    pu.DEDUCTION_KEY  AS "DEDUCTION_KEY",
    pu.PUNISHMENT_KEY AS "PUNISHMENT_KEY",
    pu.TARGET_CENTER  AS "CENTER_ID",
    REPLACE(TO_CHAR(pu.last_modified,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    params,
    PRIVILEGE_USAGES pu
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pg.ID = pu.GRANT_ID
WHERE
    pu.TARGET_SERVICE IN ('Participation',
                          'Attend',
                          'Booking')
AND                          
    pu.last_modified BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE