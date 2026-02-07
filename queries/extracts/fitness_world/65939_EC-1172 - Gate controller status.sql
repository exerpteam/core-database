-- This is the version from 2026-02-05
-- An overview of gate controller status at each center. 
SELECT DISTINCT
    cli.center,
    c.NAME,
    cli.type,
    cli.NAME,
    to_char(longtodate(cli.last_contact),'DD-MM-YYYY HH24:MI'),
    cli.STATE                                  AS client_state
    --dev.name                                   AS device_name
FROM
    devices dev
JOIN
    clients cli
JOIN
    centers c
ON
    c.id = cli.center
ON
    dev.client = cli.ID
WHERE
cli.state = 'ACTIVE'
and dev.driver = 'dk.procard.eclub.devices.drivers.gantner.tcp.GantnerTcpDriver'
AND dev.ENABLED = 1
AND cli.type = 'CONTROLLER'
AND c.ID in (:SCOPE)
ORDER BY
    cli.CENTER 

