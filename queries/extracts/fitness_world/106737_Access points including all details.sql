-- This is the version from 2026-02-05
--  
SELECT
    up.center                AS center,
	cen.name				AS Center_name,
    up.name                  AS "Access point name",
    cl.name                  AS "Specific source client",
    de.name                  AS "Specific source unit",
    ups.reader_device_sub_id AS "Specific source ID",
    upr.name                 AS "Specific source action",
    ups.external_id          AS "Specific source External ID",
    br.name                  AS "Resource",
    br.external_id           AS "Resource External ID"
FROM
    usage_points up
JOIN
    fw.usage_point_sources ups
ON
    ups.usage_point_center = up.center
AND ups.usage_point_id = up.id
JOIN
    fw.usage_point_resources upr
ON
    upr.center = ups.action_center
AND upr.id = ups.action_id
JOIN
    fw.usage_point_action_res_link upalk
ON
    upalk.action_center = ups.action_center
AND upalk.action_id = ups.action_id
JOIN
    fw.booking_resources br
ON
    br.center = upalk.resource_center
AND br.id = upalk.resource_id
JOIN
    clients cl
ON
    cl.id = ups.client_id
JOIN
    devices de
ON
    de.id = ups.reader_device_id
Join
	Centers Cen
on
	up.center = cen.id
WHERE
    up.state = 'ACTIVE'
    --AND de.driver = 'dk.procard.eclub.devices.drivers.gantner.tcp.GantnerTcpDriver'
AND cen.name not like 'OLD%'
AND up.name NOT IN ('Kiosk',
                    'Kiosks',
                    'Reception',
                    'Frontdesk',
                    'KS',
                    'FD+KS',
                    'FD',
                    'Beauty Angel',
                    'FD & KS',
                    'KIOSKS',
                    'Kiosks + FD',
                    'KS+FD',
                    'Reception + KS',
                    'Lager',
                    'Solarie')
AND up.center IN (:scope)