-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    b.center || 'bk' || b.id AS booking_id, -- needed
    --    b.center,
    --    longtodatec(b.STARTTIME,b.center) AS starttime,
    b.name                         AS booking_name,
    (b.stoptime-b.starttime)/60000 AS duration,
    b.CLASS_CAPACITY               AS CURRENT_CLASS_CAPACIY,
    
    --    b.STATE,
   '24' AS NEWCAPACITY,
    brc.BOOKING_RESOURCE_CENTER,
    brc.BOOKING_RESOURCE_ID
    
FROM
    bookings b
JOIN
    booking_resource_usage bru
ON
    b.id = bru.BOOKING_ID
AND b.center = bru.BOOKING_CENTER
JOIN
    booking_resource_configs brc
ON
    bru.BOOKING_RESOURCE_CENTER = brc.BOOKING_RESOURCE_CENTER
AND bru.BOOKING_RESOURCE_ID = brc.BOOKING_RESOURCE_ID
JOIN
    FW.BOOKING_RESOURCES br
ON
    br.CENTER = brc.BOOKING_RESOURCE_CENTER
AND br.id = brc.BOOKING_RESOURCE_ID
JOIN
    Booking_resource_groups brg
ON
    brg.ID = brc.group_id
WHERE
    b.STARTTIME > 1620432000000
AND (
        br.name LIKE 'Holdsal%'
    OR  br.name LIKE 'Bike%')
AND b.state = 'ACTIVE'

AND b.CLASS_CAPACITY = 25
AND bru.STATE = 'ACTIVE'
ORDER BY
    b.center || 'bk' || b.id