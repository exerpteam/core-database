SELECT
    ca.ID AS "ID",
    CASE ca.ref_type
        WHEN 'STAFF'
        THEN 'PERSON'
        ELSE ca.ref_type
    END AS "REF_TYPE",
    CASE
        WHEN ca.ref_type = 'BOOKING'
        THEN ca.ref_center_id || 'book' || ca.ref_id
        WHEN ca.ref_type = 'ACTIVITY'
        THEN CAST(ca.ref_id AS VARCHAR)
        WHEN ca.ref_type = 'STAFF'
        THEN cp.external_id
        ELSE 'UNKNOWN'
    END              AS "REF_ID",
    cg.id            AS "CUSTOM_ATTRIBUTE_CONFIG_ID",
    cv.id            AS "CUSTOM_ATTRIBUTE_VALUE_ID",
    ca.state         AS "STATE",
    ca.last_modified AS "ETS"
FROM
    CUSTOM_ATTRIBUTES ca
JOIN
    CUSTOM_ATTRIBUTE_CONFIG_VALUES cv
ON
    ca.custom_attribute_config_value_id = cv.id
JOIN
    CUSTOM_ATTRIBUTE_CONFIGS cg
ON
    cv.custom_attribute_config_id = cg.id
LEFT JOIN
    PERSONS p
ON
    ca.ref_center_id = p.center
AND ca.ref_id = p.id
AND ca.ref_type = 'STAFF'
LEFT JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
AND cp.ID = p.TRANSFERS_CURRENT_PRS_ID
