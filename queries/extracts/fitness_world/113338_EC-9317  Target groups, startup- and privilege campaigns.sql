-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    sc.id              AS campaign_id,
    sc.name            AS campaign_name,
    'Startup Campaign' AS source_type,
    sc.period_start    AS campaign_period_start,
    sc.period_end      AS campaign_period_end,
    CASE
        WHEN sc.plugin_codes_name = 'GENERATED'
        THEN 'Single usage'
        WHEN sc.plugin_codes_name = 'UNIQUE'
        THEN 'Multi usage'
        ELSE NULL
    END                                AS campaign_code_type,
    string_agg(DISTINCT cc.code, ', ') AS campaign_codes,
    string_agg(DISTINCT ps.name, ', ') AS privilege_sets
FROM
    fw.startup_campaign sc
JOIN
    fw.privilege_grants pg
ON
    pg.granter_service = 'StartupCampaign'
AND pg.granter_id = sc.id
JOIN
    privilege_sets ps
ON
    ps.id = pg.privilege_set
LEFT JOIN
    campaign_codes cc
ON
    cc.campaign_id = sc.id
AND cc.campaign_type = 'STARTUP'
GROUP BY
    sc.id,
    sc.name,
    sc.period_start,
    sc.period_end
UNION ALL
SELECT
    prc.id   AS campaign_id,
    prc.name AS campaign_name,
    CASE
        WHEN prc.rgtype = 'UNLIMITED'
        THEN 'Target Group'
        WHEN prc.rgtype = 'CAMPAIGN'
        THEN 'Privilege Campaign'
    END                       AS source_type,
    longtodate(prc.starttime) AS campaign_period_start,
    longtodate(prc.endtime)   AS campaign_period_end,
    CASE
        WHEN prc.plugin_codes_name = 'GENERATED'
        THEN 'Single usage'
        WHEN prc.plugin_codes_name = 'UNIQUE'
        THEN 'Multi usage'
        ELSE NULL
    END                                AS campaign_code_type,
    string_agg(DISTINCT cc.code, ', ') AS campaign_codes,
    string_agg(DISTINCT ps.name, ', ') AS privilege_sets
FROM
    fw.privilege_receiver_groups prc
JOIN
    fw.privilege_grants pg
ON
    pg.granter_service = 'ReceiverGroup'
AND pg.granter_id = prc.id
JOIN
    privilege_sets ps
ON
    ps.id = pg.privilege_set
LEFT JOIN
    campaign_codes cc
ON
    cc.campaign_id = prc.id
AND cc.campaign_type = 'RECEIVER_GROUP'
GROUP BY
    prc.id,
    prc.name