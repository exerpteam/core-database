-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    cli.center,
    c.NAME,
    cli.type,
    cli.NAME,
    cli.STATE,
    longtodate(cli.last_contact) AS "LAST CONTACT",
    MAX(longToDate(ci1.STARTUPTIME)) latest_startup,
-- 	MAX(longToDate(ci1.SHUTDOWNTIME)) latest_shutdown
    dev.name                                   AS device_name
FROM
    devices dev
JOIN
    clients cli
ON
    dev.client = cli.ID
JOIN
    centers c
ON
    c.id = cli.center
JOIN CLIENT_INSTANCES ci1
ON
    ci1.CLIENT = cli.ID

WHERE
    cli.state = 'ACTIVE'
--AND dev.driver = 'dk.procard.eclub.devices.drivers.gantner.tcp.GantnerTcpDriver'
AND dev.ENABLED = 1
AND cli.type = 'CLIENT'
AND cli.center in (:scope)
AND cli.NAME like '%FD%'
AND dev.driver = 'dk.procard.eclub.devices.drivers.pcsc.reader.PCSCGenericDriver'
GROUP BY
    cli.center,
    c.NAME,
    cli.type,
    cli.NAME,
    cli.STATE,
	cli.last_contact,
	dev.name

ORDER BY
    cli.CENTER 

