SELECT
   id                         AS "ID",
   value                      AS "VALUE",
   external_id                AS "EXTERNAL_ID",
   rank                       AS "RANK", 
   custom_attribute_config_id AS "CUSTOM_ATTRIBUTE_CONFIG_ID",
   state                      AS "STATE",
   last_modified              AS "ETS"
FROM
   CUSTOM_ATTRIBUTE_CONFIG_VALUES     
