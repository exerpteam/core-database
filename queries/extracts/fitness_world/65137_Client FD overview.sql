-- This is the version from 2026-02-05
--  
SELECT
    cl.ID,
    MAX(longToDate(ci1.STARTUPTIME)) latest_startup,
    MAX(longToDate(ci1.SHUTDOWNTIME)) latest_shutdown,
    cl.CLIENTID,
    cl.DESCRIPTION,
    cl.CENTER,
    cl.TYPE,
    cl.NAME,
    cl.STATE,
    cl.EXPIRATION_DATE
FROM
    CLIENTS cl
JOIN FW.CLIENT_INSTANCES ci1
ON
    ci1.CLIENT = cl.ID
WHERE
    center IN (:scope)
    AND cl.STATE = 'ACTIVE'
    And cl.name like '%FD%'
group by 
    cl.ID,
    cl.CLIENTID,
    cl.DESCRIPTION,
    cl.CENTER,
    cl.TYPE,
    cl.NAME,
    cl.STATE,
    cl.EXPIRATION_DATE