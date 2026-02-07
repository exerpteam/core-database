SELECT
    pu.ID AS "ID",
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
        WHEN pg.GRANTER_SERVICE in ('StartupCampaign', 'RetentionCampaign', 'ReceiverGroup')
        THEN 'CAMPAIGN'
        ELSE 'UNDEFINED'
    END "SOURCE_TYPE",
    CASE
        WHEN pg.GRANTER_SERVICE = 'GlobalCard'
        THEN pu.SOURCE_CENTER || 'cc' || pu.SOURCE_ID ||'cc'|| pu.SOURCE_SUBID
        WHEN pg.GRANTER_SERVICE = 'GlobalSubscription'
        THEN pu.SOURCE_CENTER || 'ss' || pu.SOURCE_ID
        WHEN pg.GRANTER_SERVICE = 'Access product'
        THEN pu.SOURCE_CENTER || 'inv' || pu.SOURCE_ID ||'ln'|| pu.SOURCE_SUBID
        WHEN pg.GRANTER_SERVICE = 'Addon'
        THEN '' || pu.SOURCE_ID
		WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
        THEN pg.GRANTER_CENTER || 'p' || pg.GRANTER_ID || 'rpt' || pg.GRANTER_SUBID
		WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND rg.RGTYPE ='CAMPAIGN'
        THEN 'C_' || pu.SOURCE_ID
        WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND rg.RGTYPE ='UNLIMITED'
        THEN 'TG_' || pu.SOURCE_ID
        WHEN pg.GRANTER_SERVICE = 'StartupCampaign'
        THEN 'SC_' || pg.GRANTER_ID
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
        THEN pu.TARGET_CENTER || 'pa' || pu.TARGET_ID
        WHEN pu.TARGET_SERVICE = 'Attend'
        THEN pu.TARGET_CENTER || 'att' || pu.TARGET_ID
        WHEN pu.TARGET_SERVICE = 'Booking'
        THEN pu.TARGET_CENTER || 'book' || pu.TARGET_ID
        ELSE NULL
    END "TARGET_ID",
    pu.STATE          AS "STATE",
    pu.DEDUCTION_KEY  AS "DEDUCTION_KEY",
    pu.PUNISHMENT_KEY AS "PUNISHMENT_KEY",
    pu.TARGET_CENTER  AS "CENTER_ID",
    pu.last_modified  AS "ETS",
    pu.PRIVILEGE_ID   AS "ACCESS_PRIVILEGE_ID"    
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
WHERE
    pu.TARGET_SERVICE IN ('Participation',
                          'Attend',
                          'Booking')
