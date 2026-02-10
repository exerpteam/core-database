-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.SHORTNAME                AS "Center name",
    c.ID                       AS "Center ID",
    br.NAME                    AS "Resource",
    brg.NAME                   AS "Resource group",
    brc.MAXIMUM_PARTICIPATIONS AS "Maximum participants"
FROM
    FW.BOOKING_RESOURCE_CONFIGS brc
JOIN
    FW.BOOKING_RESOURCES br
ON
    br.ID = brc.BOOKING_RESOURCE_ID
    AND br.CENTER = brc.BOOKING_RESOURCE_CENTER
LEFT JOIN
    FW.BOOKING_RESOURCE_GROUPS brg
ON
    brg.ID = brc.GROUP_ID
JOIN
    FW.CENTERS c
ON
    c.ID = br.CENTER
WHERE
    br.STATE = 'ACTIVE' 
	AND br.CENTER in (:centers)
	AND c.SHORTNAME not like 'OLD%'