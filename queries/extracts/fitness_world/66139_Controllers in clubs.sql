-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cl.ID,
    MAX(longToDate(ci1.STARTUPTIME)) latest_startup,
    MAX(longToDate(ci1.SHUTDOWNTIME)) latest_shutdown,
    cl.CLIENTID,
	cen.name,
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
Join Centers cen
on
	cl.center = cen.id
WHERE
    center IN (:scope)
  	AND cl.STATE != 'DELETED'
    And cl.TYPE = 'CONTROLLER'
group by 
    cl.ID,
	cen.name,
    cl.CLIENTID,
    cl.DESCRIPTION,
    cl.CENTER,
    cl.TYPE,
    cl.NAME,
    cl.STATE,
    cl.EXPIRATION_DATE