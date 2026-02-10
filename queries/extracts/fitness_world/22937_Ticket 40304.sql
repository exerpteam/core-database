-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    a.ID,
    a.NAME,
    a.STATE,
    brg.ID,
    brg.NAME
FROM
    FW.ACTIVITY_RESOURCE_CONFIGS arc
JOIN FW.BOOKING_RESOURCE_GROUPS brg
ON
    brg.ID = arc.BOOKING_RESOURCE_GROUP_ID
JOIN FW.ACTIVITY a
ON
    a.ID = arc.ACTIVITY_ID
WHERE
    a.STATE IN( 'ACTIVE','INACTIVE') and a.NAME is not null