-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT distinct
    cen.NAME,
    br.NAME
    
FROM
    PUREGYM.BOOKING_RESOURCES br
JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = br.CENTER
JOIN
    PUREGYM.USAGE_POINTS up
ON
    up.CENTER = cen.ID
JOIN
    PUREGYM.CLIENTS cl
    ON cl.CENTER = cen.ID 
    and cl.TYPE = 'CONTROLLER'
    and cl.LAST_CONTACT is not null    
   
WHERE
    br.NAME LIKE '%In%'
    and br.ATTEND_PRIVILEGE_ID is null
    and br.STATE = 'ACTIVE'