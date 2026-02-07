SELECT 
   id AS "ID",
   'SC_'||startup_campaign   AS "CAMPAIGN_ID",
   CASE
        WHEN ref_type = 'GLOBAL_PRODUCT'
        THEN 'GLOBAL_PRODUCT'
        WHEN ref_type = 'PRODUCT_GROUP'
        THEN 'PRODUCT_GROUP'
        WHEN ref_type = 'LOCAL_PRODUCT'
        THEN 'PRODUCT'
        ELSE ref_type 
    END AS "REF_TYPE",
       CASE
        WHEN ref_type = 'PRODUCT_GROUP'  THEN CAST(ref_id AS VARCHAR)
        WHEN ref_type = 'LOCAL_PRODUCT'  THEN ref_center||'prod'|| ref_id 
        ELSE null 
    END AS "REF_ID",
    CASE
        WHEN ref_type = 'GLOBAL_PRODUCT' THEN ref_globalid 
        ELSE null 
    END AS "REF_GLOBALID"
FROM
   STARTUP_CAMPAIGN_SUBSCRIPTION 
