-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    cen.ID,
    A.NAME,
    cen.NAME,
    cen.STARTUPDATE,
    TO_CHAR(TRUNC(longToDateTZ(cl.LAST_CONTACT,'Europe/London'),'HH'),'dd-MM-YYYY') AS "Last Heartbeat DATE",
    TO_CHAR(longtodatetz(cl.LAST_CONTACT,'Europe/London'),'HH24:MI:SS') AS "Last Heartbeat Timestamp"
        
FROM
    PUREGYM.CENTERS cen
JOIN
    PUREGYM.USAGE_POINTS up
ON
    up.CENTER = cen.ID
JOIN
    AREA_CENTERS AC
ON
    cen.ID = AC.CENTER
JOIN
    AREAS A
ON
    A.ID = AC.AREA
    -- Area Managers/UK
    AND A.PARENT = 61
JOIN
    PUREGYM.CLIENTS cl
    ON cl.CENTER = cen.ID 
    and cl.TYPE = 'CONTROLLER'
    and cl.LAST_CONTACT is not null
    
WHERE
    Cen.ID != 100