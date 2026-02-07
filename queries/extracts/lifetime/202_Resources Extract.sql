SELECT
    c.name   AS centername,
    a.name   AS state,
    c.id     AS centerid,
    br.name  AS resourcename,
    brg.name AS resourcegroup,
    brc.maximum_participations,
    br.attendable,
    br.show_calendar,
    br.state,
    br.type,
    br.external_id
FROM
    booking_resources br
JOIN
    centers c
ON
    br.center = c.id
JOIN
    booking_resource_configs brc
ON
    brc.booking_resource_center = br.center
AND brc.booking_resource_id = br.id
JOIN
    booking_resource_groups brg
ON
    brg.id = brc.group_id
JOIN
    area_centers ac
ON
    c.id = ac.center
JOIN
    areas a
ON
    a.id = ac.area
ORDER BY
    c.name ASC