-- The extract is extracted from Exerp on 2026-02-08
--  
WITH RECURSIVE cte_centers_in_area AS (
    SELECT
        AREA.id,
        AREA.parent,
        ARRAY [id] AS chain_of_command_ids,
        1 AS level
    FROM
        AREAS AREA
    WHERE
        AREA.types LIKE '%system%'
        AND AREA.parent IS NULL
    UNION
    ALL
    SELECT
        AREA.id,
        AREA.parent,
        ARRAY_APPEND(center_in_area.chain_of_command_ids, AREA.id) AS chain_of_command_ids,
        center_in_area.level + 1 AS level
    FROM
        AREAS AREA
        JOIN cte_centers_in_area center_in_area ON center_in_area.id = AREA.parent
),
cte_areas_total AS (
    SELECT
        center_in_area.id AS id,
        UNNEST(
            ARRAY_REMOVE(ARRAY_AGG(center_in_sub_area.id), NULL)
        ) AS sub_areas
    FROM
        cte_centers_in_area center_in_area
        LEFT JOIN cte_centers_in_area AS center_in_sub_area -- JOIN provides subordinates
        ON center_in_area.id = ANY (center_in_sub_area.chain_of_command_ids)
        AND center_in_area.level <= center_in_sub_area.level
    GROUP BY
        1
),
cte_all_campaigns AS (
    SELECT
        STARTUP_CAMPAIGN.id,
        'StartupCampaign' AS granter_service,
        SUBSTR(
            UNNEST(STRING_TO_ARRAY(STARTUP_CAMPAIGN.available_scopes, ',')),
            1,
            1
        ) AS scope_type,
        SUBSTR(
            UNNEST(STRING_TO_ARRAY(STARTUP_CAMPAIGN.available_scopes, ',')),
            2
        ) :: INT AS scope_id,
        STARTUP_CAMPAIGN.name,
        STARTUP_CAMPAIGN.starttime,
        STARTUP_CAMPAIGN.endtime,
        STARTUP_CAMPAIGN.period_unit,
        STARTUP_CAMPAIGN.period_value,
        STARTUP_CAMPAIGN.plugin_codes_name,
        STARTUP_CAMPAIGN.plugin_codes_config,
        STARTUP_CAMPAIGN.plugin_config
    FROM
        STARTUP_CAMPAIGN STARTUP_CAMPAIGN
        LEFT JOIN STARTUP_CAMPAIGN_SUBSCRIPTION STARTUP_CAMPAIGN_SUBSCRIPTION ON STARTUP_CAMPAIGN.id = STARTUP_CAMPAIGN_SUBSCRIPTION.startup_campaign
        LEFT JOIN PRODUCT_GROUP PRODUCT_GROUP ON STARTUP_CAMPAIGN_SUBSCRIPTION.ref_id = PRODUCT_GROUP.id
    WHERE
        STARTUP_CAMPAIGN.state = 'ACTIVE'
        AND STARTUP_CAMPAIGN.campaign_apply_for = 'NEW_SALE'
        AND TO_TIMESTAMP(STARTUP_CAMPAIGN.endtime / 1000) AT TIME ZONE GETCENTERTZ(100) > CURRENT_TIMESTAMP AT TIME ZONE GETCENTERTZ(100)
    GROUP BY
        STARTUP_CAMPAIGN.id,
        STARTUP_CAMPAIGN.name,
        STARTUP_CAMPAIGN_SUBSCRIPTION.ref_globalid,
        PRODUCT_GROUP.name
    UNION
    ALL
    SELECT
        PRIVILEGE_RECEIVER_GROUP.id,
        'ReceiverGroup' AS granter_service,
        SUBSTR(
            UNNEST(STRING_TO_ARRAY(PRIVILEGE_RECEIVER_GROUP.available_scopes, ',')),
            1,
            1
        ) AS scope_type,
        SUBSTR(
            UNNEST(STRING_TO_ARRAY(PRIVILEGE_RECEIVER_GROUP.available_scopes, ',')),
            2
        ) :: INT AS scope_id,
        PRIVILEGE_RECEIVER_GROUP.name,
        PRIVILEGE_RECEIVER_GROUP.starttime,
        PRIVILEGE_RECEIVER_GROUP.endtime,
        NULL AS period_unit,
        NULL AS period_value,
        PRIVILEGE_RECEIVER_GROUP.plugin_codes_name,
        PRIVILEGE_RECEIVER_GROUP.plugin_codes_config,
        PRIVILEGE_RECEIVER_GROUP.plugin_config
    FROM
        PRIVILEGE_RECEIVER_GROUPS PRIVILEGE_RECEIVER_GROUP
    WHERE
        PRIVILEGE_RECEIVER_GROUP.RGTYPE = 'CAMPAIGN'
        AND PRIVILEGE_RECEIVER_GROUP.BLOCKED = 0
        AND TO_TIMESTAMP(PRIVILEGE_RECEIVER_GROUP.endtime / 1000) AT TIME ZONE GETCENTERTZ(100) > CURRENT_TIMESTAMP AT TIME ZONE GETCENTERTZ(100)
),
cte_campaigns_with_scope_C AS (
    SELECT
        campaign.id,
        CENTER.id AS center_id
    FROM
        cte_all_campaigns campaign
        JOIN CENTERS CENTER ON campaign.scope_type = 'C' AND campaign.scope_id = CENTER.id
),
cte_campaigns_with_scope_A AS (
    SELECT
        campaign.id,
        AREA_CENTER.center AS center_id
    FROM
        cte_all_campaigns campaign
        JOIN cte_areas_total ON cte_areas_total.id = campaign.scope_id AND campaign.scope_type = 'A'
        JOIN AREA_CENTERS AREA_CENTER ON AREA_CENTER.area = cte_areas_total.sub_areas
),
cte_campaigns_with_scope_TG AS (
    SELECT
        campaign.id,
        CENTER.id AS center_id
    FROM
        cte_all_campaigns campaign
        JOIN CENTERS CENTER ON campaign.scope_type IN ('T', 'G')
),
-- Aggregating centers from different scopes into a unified structure
cte_campaigns_with_aggregated_centers AS (
    SELECT
        id,
        STRING_AGG(DISTINCT center_id::TEXT, ',') AS centers
    FROM (
        SELECT * FROM cte_campaigns_with_scope_C
        UNION ALL
        SELECT * FROM cte_campaigns_with_scope_A
        UNION ALL
        SELECT * FROM cte_campaigns_with_scope_TG
    )
    GROUP BY id
),
-- Simplified cte_available_campaigns focusing on joining with aggregated centers
cte_available_campaigns AS (
    SELECT
        campaign.id,
        campaign.granter_service,
        campaign.name,
        campaign.starttime,
        campaign.endtime,
        campaign.period_unit,
        campaign.period_value,
        campaign.plugin_codes_name,
        campaign.plugin_codes_config,
        campaign_with_aggregated_centers.centers,
        campaign.plugin_config
    FROM
        cte_all_campaigns campaign
        LEFT JOIN cte_campaigns_with_aggregated_centers campaign_with_aggregated_centers ON campaign_with_aggregated_centers.id = campaign.id
)
SELECT
    DISTINCT campaign.name AS "Name",
    CASE
        WHEN campaign.period_unit = 0 THEN 'Week'
        WHEN campaign.period_unit = 1 THEN 'Day'
        WHEN campaign.period_unit = 2 THEN 'Month'
        WHEN campaign.period_unit = 3 THEN 'Year'
        ELSE NULL
    END AS "RelativeUnit",
    campaign.period_value AS "RelativeValue",
    (
        TO_TIMESTAMP(campaign.starttime / 1000) AT TIME ZONE GETCENTERTZ(100)
    ) AS "StartDate",
    (
        TO_TIMESTAMP(campaign.endtime / 1000) AT TIME ZONE GETCENTERTZ(100)
    ) AS "EndDate",
    CASE
        WHEN campaign.plugin_codes_name = 'GENERATED' THEN 'Single'
        WHEN campaign.plugin_codes_name = 'UNIQUE' THEN 'Multi'
        WHEN campaign.plugin_codes_name = 'NO_CODES' THEN 'NoCodes'
        ELSE NULL
    END AS "Type",
    campaign.centers AS "Gyms",
    (
        CASE
            WHEN campaign.plugin_codes_name = 'GENERATED' THEN (
                XPATH(
                    '//configuration/value[@id="prefix"]/text/text()',
                    XMLPARSE(
                        DOCUMENT CONVERT_FROM(campaign.plugin_codes_config, 'UTF-8')
                    )
                )
            ) [1]
            WHEN campaign.plugin_codes_name = 'UNIQUE' THEN (
                XPATH(
                    '//configuration/value[@id="codes"]/text/text()',
                    XMLPARSE(
                        DOCUMENT CONVERT_FROM(campaign.plugin_codes_config, 'UTF-8')
                    )
                )
            ) [1]
            ELSE NULL
        END
    ) :: TEXT AS "CodePrefixes",
    (
        CASE
            WHEN STRING_AGG(
                CAST(PRIVILEGE_SET_INCLUDE.child_id AS TEXT),
                ','
            ) IS NULL THEN STRING_AGG(
                DISTINCT PRIVILEGE_GRANT.privilege_set :: TEXT,
                ','
            )
            ELSE CONCAT(
                STRING_AGG(
                    DISTINCT PRIVILEGE_GRANT.privilege_set :: TEXT,
                    ','
                ),
                ',',
                STRING_AGG(
                    DISTINCT PRIVILEGE_SET_INCLUDE.child_id :: TEXT,
                    ','
                )
            )
        END
    ) AS "PrivilegeSetIds",
    CAST(
        (
            XPATH(
                '//configuration/section/value[@id="personTarget"]/text/text()',
                XMLPARSE(
                    DOCUMENT CONVERT_FROM(campaign.plugin_config, 'UTF-8')
                )
            )
        ) [1] AS TEXT
    ) AS "PersonTargets"
FROM
    cte_available_campaigns campaign
    LEFT JOIN PRIVILEGE_GRANTS PRIVILEGE_GRANT ON PRIVILEGE_GRANT.granter_id = campaign.id
    AND PRIVILEGE_GRANT.granter_service = campaign.granter_service
    AND (PRIVILEGE_GRANT.valid_to IS NULL
    OR TO_TIMESTAMP(PRIVILEGE_GRANT.valid_to / 1000) AT TIME ZONE GETCENTERTZ(100) > CURRENT_TIMESTAMP AT TIME ZONE GETCENTERTZ(100))
    LEFT JOIN PRIVILEGE_SET_INCLUDES PRIVILEGE_SET_INCLUDE ON PRIVILEGE_GRANT.privilege_set = PRIVILEGE_SET_INCLUDE.parent_id
GROUP BY
    campaign.id,
    campaign.name,
    campaign.period_unit,
    campaign.period_value,
    campaign.starttime,
    campaign.endtime,
    campaign.plugin_codes_name,
    campaign.centers,
    campaign.plugin_codes_config,
    campaign.plugin_config
