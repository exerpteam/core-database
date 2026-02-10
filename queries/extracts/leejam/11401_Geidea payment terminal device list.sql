-- The extract is extracted from Exerp on 2026-02-08
-- EC-5748
SELECT
    d.name   AS "DEVICE_NAME",
    c.name   AS "CLIENT_NAME",
    c.center AS "CENTER_ID"
FROM
    devices d
JOIN
    clients c
ON
    c.id=d.client
AND c.type='CLIENT'
AND c.state='ACTIVE'
WHERE
    d.driver=
    'dk.procard.eclub.devices.drivers.geidea.terminal.webecr.GeideaCardTerminalDeviceDriver'
AND d.enabled=true