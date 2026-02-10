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
    br.CENTER              AS "CENTER_ID"
	FROM
    booking_resource_groups brg
LEFT JOIN
    booking_resource_configs brc
ON
    brc.group_id = brg.id
LEFT JOIN
    booking_resources br
ON
    br.center = brc.booking_resource_center
    AND br.id = brc.booking_resource_id
LEFT JOIN
    activity_resource_configs arc
ON
    arc.booking_resource_group_id = brg.id
LEFT JOIN
    ACTIVITY ac
ON
    ac.ID = arc.activity_id