-- The extract is extracted from Exerp on 2026-02-08
-- non ended startup campaign and privilege campaign IDs with their plugins and code plugins - limitation doesn't work for SQL type plugin as it is stored as different type
WITH extracted AS (
  SELECT
    'SC_' || sc.id AS campaign_id,
    sc.plugin_name,
    (xpath('string((/descendant-or-self::*/@*[local-name()="id"])[1])', sec))[1]::text AS section_id,
    sv.key_id,
    sv.value_txt,
    sc.plugin_codes_name,
    (xpath('string(/configuration/value[@id="codes"]/text)',        convert_from(sc.plugin_codes_config,'UTF8')::xml))[1]::text AS multi_usage_codes,
    (xpath('string(/configuration/value[@id="maxUsage"]/text)',     convert_from(sc.plugin_codes_config,'UTF8')::xml))[1]::text AS max_usage_per_member,
    (xpath('string(/configuration/value[@id="prefix"]/text)',       convert_from(sc.plugin_codes_config,'UTF8')::xml))[1]::text AS code_prefix,
    (xpath('string(/configuration/value[@id="numberOfCodes"]/text)',convert_from(sc.plugin_codes_config,'UTF8')::xml))[1]::text AS number_of_codes_generated
  FROM startup_campaign sc
  CROSS JOIN LATERAL (
    SELECT sec
    FROM unnest(
      xpath('/child::*[local-name()="configuration"]/child::*[local-name()="section"]',
            convert_from(sc.plugin_config,'UTF8')::xml)
    ) AS t(sec)
  ) s
  CROSS JOIN LATERAL (
    SELECT
      ARRAY(SELECT x::text FROM unnest(xpath('.//value/@id', s.sec)) AS x) AS val_ids,
      ARRAY(SELECT x::text FROM unnest(xpath('.//value/child::*[local-name()="text"]/text()', s.sec)) AS x) AS val_txts
  ) v
  CROSS JOIN LATERAL (
    SELECT v.val_ids[idx] AS key_id, v.val_txts[idx] AS value_txt
    FROM generate_series(1, COALESCE(array_length(v.val_ids,1),0)) AS g(idx)
  ) sv
  WHERE sc.state = 'ACTIVE'
    AND longtodateC(sc.endtime, 100) >= CURRENT_DATE

  UNION ALL

  SELECT
    'C_' || rg.id AS campaign_id,
    rg.plugin_name,
    (xpath('string((/descendant-or-self::*/@*[local-name()="id"])[1])', sec))[1]::text AS section_id,
    sv.key_id,
    sv.value_txt,
    rg.plugin_codes_name,
    (xpath('string(/configuration/value[@id="codes"]/text)',        convert_from(rg.plugin_codes_config,'UTF8')::xml))[1]::text AS multi_usage_codes,
    (xpath('string(/configuration/value[@id="maxUsage"]/text)',     convert_from(rg.plugin_codes_config,'UTF8')::xml))[1]::text AS max_usage_per_member,
    (xpath('string(/configuration/value[@id="prefix"]/text)',       convert_from(rg.plugin_codes_config,'UTF8')::xml))[1]::text AS code_prefix,
    (xpath('string(/configuration/value[@id="numberOfCodes"]/text)',convert_from(rg.plugin_codes_config,'UTF8')::xml))[1]::text AS number_of_codes_generated
  FROM privilege_receiver_groups rg
  CROSS JOIN LATERAL (
    SELECT sec
    FROM unnest(
      xpath('/child::*[local-name()="configuration"]/child::*[local-name()="section"]',
            convert_from(rg.plugin_config,'UTF8')::xml)
    ) AS t(sec)
  ) s
  CROSS JOIN LATERAL (
    SELECT
      ARRAY(SELECT x::text FROM unnest(xpath('.//value/@id', s.sec)) AS x) AS val_ids,
      ARRAY(SELECT x::text FROM unnest(xpath('.//value/child::*[local-name()="text"]/text()', s.sec)) AS x) AS val_txts
  ) v
  CROSS JOIN LATERAL (
    SELECT v.val_ids[idx] AS key_id, v.val_txts[idx] AS value_txt
    FROM generate_series(1, COALESCE(array_length(v.val_ids,1),0)) AS g(idx)
  ) sv
  WHERE rg.rgtype = 'CAMPAIGN'
    AND rg.blocked = false
    AND longtodateC(rg.endtime, 100) >= CURRENT_DATE
),
section_maps AS (
  SELECT
    campaign_id,
    section_id,
    plugin_name,
    jsonb_object_agg(
      key_id,
      CASE WHEN key_id = 'productPrivilegeRefs' AND value_txt LIKE '[%' THEN value_txt::jsonb
           ELSE to_jsonb(value_txt)
      END
    ) AS section_map,
    plugin_codes_name,
    multi_usage_codes,
    max_usage_per_member,
    code_prefix,
    number_of_codes_generated
  FROM extracted
  GROUP BY campaign_id, section_id, plugin_name,
           plugin_codes_name, multi_usage_codes,
           max_usage_per_member, code_prefix, number_of_codes_generated
)
SELECT
  campaign_id,
  plugin_name,
  jsonb_object_agg(section_id, section_map) AS plugin_config,
  CASE
    WHEN plugin_codes_name = 'UNIQUE'    THEN 'MULTI_USEAGE'
    WHEN plugin_codes_name = 'GENERATED' THEN 'SINGLE_USAGE'
    ELSE plugin_codes_name
  END AS codes_plugin_name,
  multi_usage_codes,
  max_usage_per_member,
  code_prefix,
  number_of_codes_generated
FROM section_maps
GROUP BY campaign_id, plugin_name, plugin_codes_name,
         multi_usage_codes, max_usage_per_member, code_prefix, number_of_codes_generated;
