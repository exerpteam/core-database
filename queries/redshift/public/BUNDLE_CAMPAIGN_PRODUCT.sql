SELECT
    bcp.ID                     AS "ID",
    'BC_'||bcp.BUNDLE_CAMPAIGN AS "CAMPAIGN_ID",
    bcp.REF_TYPE               AS "REF_TYPE",
    CASE
        WHEN bcp.REF_TYPE = 'LOCAL_PRODUCT'
        THEN bcp.REF_CENTER||'prod'||bcp.REF_ID
        WHEN bcp.REF_TYPE = 'PRODUCT_GROUP'
        THEN CAST(bcp.REF_ID AS VARCHAR(255))
        WHEN bcp.REF_TYPE = 'GLOBAL_PRODUCT'
        THEN bcp.REF_GLOBALID
    END         AS "REF_ID",
    bcp.UNITS   AS "UNITS",
    CAST(CAST (bcp.REBATED AS INT) AS SMALLINT)  AS "REBATED" 
FROM
    BUNDLE_CAMPAIGN_PRODUCT bcp