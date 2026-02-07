-- This is the version from 2026-02-05
--  
SELECT
    br.CENTER||'br'||br.ID AS "RESOURCE_ID",
    br.NAME                AS "NAME",
    br.STATE               AS "STATE",
    br.TYPE                AS "TYPE",
    bpg.NAME               AS "ACCESS_GROUP_NAME",
    br.EXTERNAL_ID         AS "EXTERNAL_ID",
	br.CENTER              AS "RESOURCE_CENTER_ID",
	br.CENTER              AS "CENTER_ID"
FROM
    BOOKING_RESOURCES br
LEFT JOIN
    BOOKING_PRIVILEGE_GROUPS bpg
ON
    bpg.ID = br.ATTEND_PRIVILEGE_ID
