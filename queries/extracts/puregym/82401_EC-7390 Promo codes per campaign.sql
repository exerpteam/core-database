-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT DISTINCT
            NAME AS "Campaign Name",
            CASE
                 WHEN PLUGIN_CODES_NAME = 'GENERATED'
                 THEN 'SINGLE USE'
                 WHEN PLUGIN_CODES_NAME = 'UNIQUE'
                 THEN 'MULTI USE'
                 ELSE 'UNKNOWN'
             END AS "Code type",
             CASE
                 WHEN USAGE_COUNT > 0
                 AND PLUGIN_CODES_NAME = 'GENERATED'
                 THEN 'REDEEMED'
                 WHEN USAGE_COUNT = 0
                 AND PLUGIN_CODES_NAME = 'GENERATED'
                 THEN 'AVAILABLE'
                 ELSE 'N/A'
             END AS "Usage",
			APPLY,
             CODE AS "Promo Code"
 FROM
     (
         SELECT
             sc.ID,
             sc.NAME,
             sc.PLUGIN_CODES_NAME,
             cc.CODE,
             cc.USAGE_COUNT,
             sc.campaign_apply_for AS APPLY
         FROM
             STARTUP_CAMPAIGN sc
         JOIN
             CAMPAIGN_CODES cc
         ON
             cc.CAMPAIGN_ID = sc.ID
         AND cc.CAMPAIGN_TYPE = 'STARTUP'
         WHERE
         sc.PLUGIN_CODES_NAME != 'NO_CODES'
         UNION
                  SELECT
             prg.ID,
             prg.NAME,
             prg.PLUGIN_CODES_NAME,
             cc.CODE,
             cc.USAGE_COUNT,
             ' ' AS APPLY
         FROM
             PRIVILEGE_RECEIVER_GROUPS prg
         JOIN
             CAMPAIGN_CODES cc
         ON
             cc.CAMPAIGN_ID = prg.ID
         AND cc.CAMPAIGN_TYPE = 'RECEIVER_GROUP'
         WHERE
         prg.PLUGIN_CODES_NAME != 'NO_CODES' 
        ) t1
         WHERE
         ID IN (:code)
