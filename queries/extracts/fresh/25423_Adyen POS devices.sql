-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    pmp_xml AS
    (
        SELECT
            d2.id,
            CAST(convert_from(d2.configuration, 'UTF-8') AS XML) AS pxml
        FROM
            devices d2
    )
SELECT
center_id,
center_name,
client_name,
client_id,
--client_ip,
client_mac,
client_startuptime,
device_name,
CAST(UNNEST(xpath('//properties/ip/text()', pmp_xml.pxml)) AS VARCHAR(100)) AS device_ip
FROM
(
SELECT
ce.id AS center_id,
ce.name AS center_name,
c.name AS client_name,
c.clientid AS client_id,
--ci.ipaddress AS client_ip,
ci.macaddress AS client_mac,
longtodate(MAX(ci.startuptime)) AS client_startuptime,
d.id,
d.name AS device_name
FROM
clients c
JOIN
devices d
ON
d.client = c.id
JOIN
centers ce
ON
ce.id = c.center
JOIN
client_instances ci
ON
ci.client = c.id
WHERE
d.driver = 'dk.procard.eclub.devices.drivers.adyen.AdyenCardTerminalDriver'
AND d.enabled = true
AND c.state = 'ACTIVE'
AND ci.startuptime >= CAST(datetolong(TO_CHAR(TO_DATE((:date), 'YYYY-MM-DD'), 'YYYY-MM-DD')) AS BIGINT)
AND ce.id IN (:scope)
GROUP BY
ce.id,
ce.name,
c.name,
c.clientid,
--ci.ipaddress,
ci.macaddress,
d.id,
d.name
) t1
JOIN
pmp_xml
ON
pmp_xml.id = t1.id
ORDER BY
center_id,
device_ip