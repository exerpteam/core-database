-- This is the version from 2026-02-05
--  
SELECT 
    cli.center,
    c.NAME,
    cli.type,
    cli.NAME,
    cli.STATE                                  AS client_state,
	dev.driver								   AS driver_name,
	dev.name                                   AS device_name,
    MAX(longToDate(ci1.STARTUPTIME)) latest_startup,
    MAX(longToDate(ci1.SHUTDOWNTIME)) latest_shutdown
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
AND dev.driver in ('dk.procard.eclub.devices.drivers.metrologic.MetroLogicBarcodeReaderDriver', 'dk.procard.eclub.devices.drivers.acr.ACRTerminalDriver', 'dk.procard.eclub.devices.drivers.epson.EpsonReceiptPrinterDriver', 'dk.procard.eclub.devices.drivers.point.dk.v36.PointTerminalDriver')
AND dev.ENABLED = 1
AND cli.type = 'CLIENT'
AND cli.NAME like '%FD%'
AND cli.CENTER in (:scope)
GROUP by
	cli.center,
    c.NAME,
    cli.type,
    cli.NAME,
    cli.STATE,
	dev.driver,
	dev.name
ORDER BY
    cli.CENTER 
