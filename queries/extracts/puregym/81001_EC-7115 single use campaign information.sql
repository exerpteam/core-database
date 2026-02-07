WITH
    RECURSIVE centers_in_area AS
    (
        SELECT
            a.id,
            a.parent,
            ARRAY[id] AS chain_of_command_ids,
            1         AS level
        FROM
            areas a
        WHERE
            a.types LIKE '%system%'
        AND a.parent IS NULL
        UNION ALL
        SELECT
            a.id,
            a.parent,
            array_append(cin.chain_of_command_ids, a.id) AS chain_of_command_ids,
            cin.level + 1                                AS level
        FROM
            areas a
        JOIN
            centers_in_area cin
        ON
            cin.id = a.parent
    )
    ,
    areas_total AS
    (
        SELECT
            cin.id                                      AS ID,
            unnest(array_remove(array_agg(b.ID), NULL)) AS sub_areas
        FROM
            centers_in_area cin
        LEFT JOIN
            centers_in_area AS b -- join provides subordinates
        ON
            cin.id = ANY (b.chain_of_command_ids)
        AND cin.level <= b.level
        GROUP BY
            1
    )
    ,
    all_c AS
    (
        SELECT
            st.id,
            'SC'                                                      AS campaign_type,
            'StartupCampaign'                                             AS granter_service ,
            SUBSTR(unnest(string_to_array(st.available_scopes, ',')),1,1)    AS scope_type,
            SUBSTR(unnest(string_to_array(st.available_scopes, ',')),2)::INT AS scope_id,
            st.name,
            st.starttime,
            st.endtime,
            st.period_unit,
            st.period_value,
            CASE
                WHEN plugin_codes_name = 'GENERATED'
                THEN 'Single'
                WHEN plugin_codes_name = 'UNIQUE'
                THEN 'Multi'
                ELSE NULL
            END AS plugin_codes_name,
            (
                CASE
                    WHEN plugin_codes_name = 'GENERATED'
                    THEN (xpath('//configuration/value[@id="prefix"]/text/text()',xmlparse(document
                        convert_from(st.plugin_codes_config, 'UTF-8')) ))[1]
                    WHEN plugin_codes_name = 'UNIQUE'
                    THEN (xpath('//configuration/value[@id="codes"]/text/text()',xmlparse(document
                        convert_from (st.plugin_codes_config, 'UTF-8')) ))[1]
                    ELSE NULL
                END)::text AS codes,
            cast((xpath('//configuration/value[@id="campaignIsExclusive"]/text/text()',xmlparse(document
            convert_from(st.plugin_codes_config, 'UTF-8')) ))[1] as text) AS campaign_is_exclusive
        FROM
            STARTUP_CAMPAIGN st
        WHERE
            st.state = 'ACTIVE'
        AND st.endtime > datetolong(CURRENT_DATE::text)
        AND st.plugin_codes_name IN('GENERATED',
                                    'UNIQUE')
        UNION ALL
        SELECT
            st.id,
            'C'                                                        AS campaign_type,
            'ReceiverGroup'                                               AS granter_service ,
            SUBSTR(unnest(string_to_array(st.available_scopes, ',')),1,1)    AS scope_type,
            SUBSTR(unnest(string_to_array(st.available_scopes, ',')),2)::INT AS scope_id,
            st.name,
            st.starttime,
            st.endtime,
            NULL AS period_unit,
            NULL AS period_value,
            CASE
                WHEN plugin_codes_name = 'GENERATED'
                THEN 'Single'
                WHEN plugin_codes_name = 'UNIQUE'
                THEN 'Multi'
                ELSE NULL
            END AS plugin_codes_name,
            (
                CASE
                    WHEN plugin_codes_name = 'GENERATED'
                    THEN (xpath('//configuration/value[@id="prefix"]/text/text()',xmlparse(document
                        convert_from(st.plugin_codes_config, 'UTF-8')) ))[1]
                    WHEN plugin_codes_name = 'UNIQUE'
                    THEN (xpath('//configuration/value[@id="codes"]/text/text()',xmlparse(document
                        convert_from (st.plugin_codes_config, 'UTF-8')) ))[1]
                    ELSE NULL
                END)::text AS codes,
            NULL           AS campaign_is_exclusive
        FROM
            PRIVILEGE_RECEIVER_GROUPS st
        WHERE
            st.RGTYPE ='CAMPAIGN'
        AND st.BLOCKED= 0
        AND st.endtime > datetolong(CURRENT_DATE::text)
        AND st.plugin_codes_name IN('GENERATED',
                                    'UNIQUE')
    )
    ,
    c_avail AS
    (
        SELECT
            st.id,
            campaign_type,
            granter_service,
            st.name,
            st.starttime,
            st.endtime,
            st.period_unit,
            st.period_value,
            st.plugin_codes_name,
            st.codes,
            st.campaign_is_exclusive,
            STRING_AGG( DISTINCT
            CASE
                WHEN st.scope_type = 'C' -- override on center
                THEN st.scope_id::text
                ELSE
                    CASE
                        WHEN c.id IS NOT NULL -- override on tree
                        THEN c.ID::text
                        ELSE ac.center::text
                    END
            END ,',') AS centers
        FROM
            all_c st
        LEFT JOIN
            areas_total
        ON
            areas_total.id = st.scope_id
        AND st.scope_type = 'A'
        LEFT JOIN
            area_centers ac
        ON
            ac.area = areas_total.sub_areas
        JOIN
            centers c
        ON
            st.scope_type IN ('T',
                              'G')
        OR  ( st.scope_type = 'C'
            AND st.scope_id = c.id)
        OR  ( st.scope_type = 'A'
            AND ac.CENTER = c.id)
        GROUP BY
            st.id,
            st.campaign_type,
            st.granter_service,
            st.name,
            st.starttime,
            st.endtime,
            st.period_unit,
            st.period_value,
            st.plugin_codes_name,
            st.codes,
            st.campaign_is_exclusive
    )
SELECT DISTINCT
    st.NAME AS "Campaign Name",
    CASE
        WHEN st.period_unit = 0
        THEN 'WEEK'
        WHEN st.period_unit =1
        THEN 'DAY'
        WHEN st.period_unit = 2
        THEN 'MONTH'
        WHEN st.period_unit = 3
        THEN 'YEAR'
        WHEN st.period_unit =4
        THEN 'HOUR'
        WHEN st.period_unit = 5
        THEN 'MINUTE'
        WHEN st.period_unit = 6
        THEN 'SECOND'
        WHEN st.period_unit IS NULL
        THEN NULL
        ELSE 'UNKNOWN'
    END                                                                    AS "relative start unit",
    st.period_value                                                       AS "relative start value",
    to_date(TO_CHAR(longtodateC(st.STARTTIME,100),'yyyy-MM-dd'),'yyyy-MM-dd') AS "Start Date",
    to_date(TO_CHAR(longtodateC(st.ENDTIME,100),'yyyy-MM-dd'),'yyyy-MM-dd')   AS "End Date",
    st.PLUGIN_CODES_NAME                                                      AS "Code type",
    st.centers,
    st.codes,
    STRING_AGG(DISTINCT pg.privilege_set::text,',') AS "Privilege sets",
    st.campaign_is_exclusive
FROM
    c_avail st
LEFT JOIN
    puregym.privilege_grants pg
ON
    pg.granter_id = st.id
AND pg.granter_service = st.granter_service
GROUP BY
    st.campaign_type,
    st.ID,
    st.NAME,
    st.period_unit,
    st.period_value,
    st.STARTTIME,
    st.ENDTIME,
    st.PLUGIN_CODES_NAME,
    st.centers,
    st.codes,
    st.campaign_is_exclusive