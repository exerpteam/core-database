SELECT
    pg.ID AS "ID",
    CASE
        WHEN pg.GRANTER_SERVICE IN('GlobalCard',
                                   'GlobalSubscription',
                                   'Access product',
                                   'Addon')
        THEN 'MASTER_PRODUCT'
        WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
        THEN 'COMPANY_AGREEMENT'
        WHEN pg.GRANTER_SERVICE IN( 'ReceiverGroup',
                                   'StartupCampaign','RetentionCampaign')
        THEN 'CAMPAIGN'
        ELSE 'UNDEFINED'
    END AS "SOURCE_TYPE",
    CASE
        WHEN pg.GRANTER_SERVICE = 'CompanyAgreement'
        THEN pg.GRANTER_CENTER||'p'||pg.GRANTER_ID||'rpt'||pg.GRANTER_SUBID
        WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND rg.RGTYPE ='CAMPAIGN'
        THEN 'C_' || pg.GRANTER_ID
        WHEN pg.GRANTER_SERVICE = 'ReceiverGroup'
            AND rg.RGTYPE ='UNLIMITED'
        THEN 'TG_' || pg.GRANTER_ID
        WHEN pg.GRANTER_SERVICE in ('StartupCampaign','RetentionCampaign')
        THEN 'SC_' || pg.GRANTER_ID
        WHEN pg.GRANTER_SERVICE IN('GlobalCard',
                                   'GlobalSubscription',
                                   'Access product',
                                   'Addon')
        THEN '' || GRANTER_ID
    END                 "SOURCE_ID",
    pg.PRIVILEGE_SET      AS "PRIVILEGE_SET_ID",
    pg.SPONSORSHIP_NAME   AS "SPONSORSHIP_TYPE",
    pg.SPONSORSHIP_AMOUNT   AS "SPONSORSHIP_AMOUNT",
    pg.usage_quantity       AS "USAGE_QUANTITY",
    pg.usage_duration_value AS "USAGE_DURATION_VALUE",
    CASE
        WHEN pg.usage_duration_unit = 0
        THEN 'WEEK'
        WHEN pg.usage_duration_unit = 1
        THEN 'DAY'
        WHEN pg.usage_duration_unit = 2
        THEN 'MONTH'
        WHEN pg.usage_duration_unit = 3
        THEN 'YEAR'
        WHEN pg.usage_duration_unit = 4
        THEN 'HOUR'
        WHEN pg.usage_duration_unit = 5
        THEN 'MINUTE'
        WHEN pg.usage_duration_unit = 6
        THEN 'SECOND'
        WHEN pg.usage_duration_unit IS NULL
        THEN NULL
        ELSE 'UNKNOWN'
    END AS "USAGE_DURATION_UNIT"
FROM
    PRIVILEGE_GRANTS pg
LEFT JOIN
    PRIVILEGE_RECEIVER_GROUPS rg
ON
    pg.GRANTER_SERVICE = 'ReceiverGroup'
    AND rg.ID = pg.GRANTER_ID
WHERE
    pg.VALID_TO IS NULL