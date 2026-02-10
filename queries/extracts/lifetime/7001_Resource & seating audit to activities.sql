-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ES-22702
SELECT
    c.name AS center_name,
    c.id,
    --a.name   AS activity_name,
    br.name  AS resource_name,
    brg.name AS resource_group,
    case when a.seat_booking_support_type = 0 then FALSE
        WHEN A.seat_booking_support_type = 1 THEN TRUE
        END AS seat_configured_on_activity,
case when bs.resource_center is null and bs.resource_id is null then
        false
        else true end as seat_configured_on_resource
FROM
    lifetime.booking_resource_groups brg
JOIN
    booking_resource_configs brc
ON
    brg.id = brc.group_id
JOIN
    booking_resources br
ON
    brc.booking_resource_center = br.center
AND brc.booking_resource_id = br.id
AND BR.state = 'ACTIVE'
JOIN
    centers c
ON
    c.id = br.center
JOIN
    activity_resource_configs arc
ON
    arc.booking_resource_group_id = brg.id
JOIN
    activity a
ON
    a.id = arc.activity_id
    and a.state = 'ACTIVE'
--AND a.seat_booking_support_type = 1
LEFT JOIN
    booking_seats bs
ON
    br.center = bs.resource_center
AND br.id = bs.resource_id
    WHERE c.id in ($$scope$$)
GROUP BY
    c.name,
    c.id,
    br.name,
    brg.name,
    a.seat_booking_support_type,
    bs.resource_center,
    bs.resource_id
ORDER BY
    1,3,4,5,6