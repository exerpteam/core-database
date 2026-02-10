-- The extract is extracted from Exerp on 2026-02-08
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
    AND not EXISTS
    (
        SELECT
            *
        FROM
            FW.CLIENT_INSTANCES ci
        WHERE
            ci.CLIENT = cl.ID
            AND (ci.SHUTDOWNTIME > 1338501600000)
    )
group by 
    cl.ID,
    cl.CLIENTID,
    cl.DESCRIPTION,
    cl.CENTER,
    cl.TYPE,
    cl.NAME,
    cl.STATE,
    cl.EXPIRATION_DATE