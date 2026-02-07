SELECT
    bp.ID            "ID",
    bp.PRIVILEGE_SET "PRIVILEGE_SET_ID",
    bp.GROUP_ID      "ACCESS_GROUP_ID",
    CASE
        WHEN ps.SCOPE_TYPE = 'C'
        THEN 'CENTER'
        WHEN ps.SCOPE_TYPE = 'A'
        THEN 'AREA'
        WHEN ps.SCOPE_TYPE = 'T'
        THEN 'GLOBAL'
    END AS      "SCOPE_TYPE",
    ps.SCOPE_ID "SCOPE_ID",
    --API
    (xpath('/timeConfiguration/userInterface[@type="API"]/span/text() ' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text AS "IN_ADVANCE_API_VALUE",
    (xpath('/timeConfiguration/userInterface[@type="API"]/round/text() ' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text AS "IN_ADVANCE_API_ROUND",
    (xpath('/timeConfiguration/userInterface[@type="API"]/span/@unit' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text AS "IN_ADVANCE_API_UNIT",
    --CLIENT
    (xpath('/timeConfiguration/userInterface[@type="CLIENT"]/span/text() ' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text AS "IN_ADVANCE_CLIENT_VALUE",
    (xpath('/timeConfiguration/userInterface[@type="CLIENT"]/round/text() ' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text AS "IN_ADVANCE_CLIENT_ROUND",
    (xpath('/timeConfiguration/userInterface[@type="CLIENT"]/span/@unit' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text  AS "IN_ADVANCE_CLIENT_UNIT",
    --KIOSK
    (xpath('/timeConfiguration/userInterface[@type="KIOSK"]/span/text() ' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text  AS "IN_ADVANCE_KIOSK_VALUE",
    (xpath('/timeConfiguration/userInterface[@type="KIOSK"]/round/text() ' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text  AS "IN_ADVANCE_KIOSK_ROUND",
    (xpath('/timeConfiguration/userInterface[@type="KIOSK"]/span/@unit' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text  AS "IN_ADVANCE_KIOSK_UNIT",
    --WEB
    (xpath('/timeConfiguration/userInterface[@type="WEB"]/span/text() ' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text  AS "IN_ADVANCE_WEB_VALUE",
    (xpath('/timeConfiguration/userInterface[@type="WEB"]/round/text() ' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text AS "IN_ADVANCE_WEB_ROUND",
    (xpath('/timeConfiguration/userInterface[@type="WEB"]/span/@unit' , xmlparse(document convert_from(bp.time_conf, 'UTF-8'))))[1]::text AS "IN_ADVANCE_WEB_UNIT"
FROM
    BOOKING_PRIVILEGES bp
LEFT JOIN
    PRIVILEGE_SETS ps
ON
    bp.PRIVILEGE_SET = ps.ID
WHERE
    bp.VALID_TO IS NULL