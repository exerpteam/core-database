-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    br.center AS "Scope",
    brg.name  AS "Resource Group",
    brg.state AS "Resource Group state",
    br.name   AS "Resource",
    br.state  AS "Resource state",
    ac.name   AS "Activity",
    ac.state  AS "Activity state"
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
WHERE
    brg.name IN ($$resource_group_name$$)