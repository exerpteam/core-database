SELECT
    'SC_'||sc.ID AS "CAMPAIGN_ID",
    CASE
        WHEN sc.available_scopes LIKE 'C%'
        THEN 'CENTER'
        WHEN sc.available_scopes LIKE 'A%'
        THEN 'AREA'
        WHEN sc.available_scopes LIKE 'T%'
            OR sc.available_scopes LIKE 'G%'
        THEN 'GLOBAL'
    END AS "SCOPE_TYPE",
    CASE
        WHEN sc.available_scopes LIKE 'T%'
            OR sc.available_scopes LIKE 'G%'
        THEN 0
        ELSE SUBSTR(available_scopes, 2, LENGTH(available_scopes) )::INTEGER
    END AS "SCOPE_ID"
FROM
    (
        SELECT
            sc.ID,
            regexp_split_to_table(available_scopes, ',') AS available_scopes
        FROM
            startup_campaign sc
        WHERE
            available_scopes IS NOT NULL
            AND available_scopes != '') sc
UNION ALL
SELECT
    CASE
        WHEN rg.RGTYPE ='CAMPAIGN'
        THEN 'C_'||rg.ID
        WHEN rg.RGTYPE ='UNLIMITED'
        THEN 'TG_'||rg.ID
    END AS "CAMPAIGN_ID",
    CASE
        WHEN rg.available_scopes LIKE 'C%'
        THEN 'CENTER'
        WHEN rg.available_scopes LIKE 'A%'
        THEN 'AREA'
        WHEN rg.available_scopes LIKE 'T%'
            OR rg.available_scopes LIKE 'G%'
        THEN 'GLOBAL'
    END AS "SCOPE_TYPE",
    CASE
        WHEN rg.available_scopes LIKE 'T%'
            OR rg.available_scopes LIKE 'G%'
        THEN 0
        ELSE SUBSTR(available_scopes, 2, LENGTH(available_scopes) )::INTEGER
    END AS "SCOPE_ID"
FROM
    (
        SELECT
            rg.ID,
            rg.RGTYPE,
            regexp_split_to_table(available_scopes, ',') AS available_scopes
        FROM
            PRIVILEGE_RECEIVER_GROUPS rg
        WHERE
            available_scopes IS NOT NULL
            AND available_scopes != '') rg
UNION ALL
SELECT
    'BC_'||bc.ID AS "CAMPAIGN_ID",
    CASE
        WHEN bc.SCOPE_TYPE = 'A'
        THEN 'AREA'
        WHEN bc.SCOPE_TYPE = 'C'
        THEN 'CENTER'
        WHEN bc.SCOPE_TYPE = 'T'
        THEN 'GLOBAL'
    END AS "SCOPE_TYPE",
    CASE
        WHEN bc.SCOPE_TYPE = 'T'
        THEN 0
        ELSE CAST(bc.SCOPE_ID AS INTEGER) 
	END AS "SCOPE_ID"
FROM
    BUNDLE_CAMPAIGN bc