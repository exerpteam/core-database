-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.id    AS center_id,
    c.name  AS center_name,
    up.name AS access_point_name,
    up.all_clients,
    up.all_kiosks,
    upr.name           AS action_name,
    upr.resource_order AS action_order,
    br.name            AS RESOURCE,
    upr.resource_usage,
    ga.name             gate,
    --ga.device_sub_id AS gate_id,
    upr.check_out,
    upr.handback_check,
    upr.print_ticket,
    upr.auto_execution_kiosk,
    cl.name   AS connected_client,
    de.name   AS device,
    de.driver AS device_driver
FROM
    usage_points up
JOIN
    centers c
ON
    c.id = up.center
JOIN
    usage_point_resources upr
ON
    upr.usage_point_center = up.center
AND upr.usage_point_id = up.id
LEFT JOIN
    usage_point_action_res_link upal
ON
    upal.action_center = upr.center
AND upal.action_id = upr.id
LEFT JOIN
    booking_resources br
ON
    br.center = upal.resource_center
AND br.id = upal.resource_id
LEFT JOIN
    usage_point_sources ups
ON
    ups.action_center = upr.center
AND ups.action_id = upr.id
LEFT JOIN
    devices de
ON
    de.id = ups.reader_device_id
LEFT JOIN
    clients cl
ON
    cl.id = ups.client_id
LEFT JOIN
    gates ga
ON
    ga.center = upr.gate_center
AND ga.id = upr.gate_id
WHERE
    up.state = 'ACTIVE'
ORDER BY
    up.center,
    up.id,
    upr.resource_order