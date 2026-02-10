-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    br.CENTER||'br'||br.ID AS "RESOURCE_ID",
    br.NAME                AS "NAME",
    br.STATE               AS "STATE",
    br.TYPE                AS "TYPE",
    bpg.NAME               AS "ACCESS_GROUP_NAME",
    br.EXTERNAL_ID         AS "EXTERNAL_ID",
    br.CENTER              AS "RESOURCE_CENTER_ID",
    br.CENTER              AS "CENTER_ID",
    br.ATTENDABLE,
    brg.NAME AS "RESOURCE_GROUP_NAME",
    brc.MAXIMUM_PARTICIPATIONS
FROM
    BOOKING_RESOURCES br
LEFT JOIN
    BOOKING_PRIVILEGE_GROUPS bpg
ON
    bpg.ID = br.ATTEND_PRIVILEGE_ID
LEFT JOIN
    FW.BOOKING_RESOURCE_CONFIGS brc
ON
    brc.BOOKING_RESOURCE_CENTER = br.CENTER
AND brc.BOOKING_RESOURCE_ID = br.ID
LEFT JOIN
    FW.BOOKING_RESOURCE_GROUPS brg
ON
    brg.ID = brc.GROUP_ID
WHERE
     br.STATE != 'DELETED'