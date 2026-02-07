SELECT
    t.center_id   AS "Center ID",
    t.center_name AS "Center Name",
    t.usage_date  AS "Usage Date",
    COUNT(t.*)    AS "Count"
FROM
    (
        SELECT
            TO_CHAR(longtodateC(att.start_time, att.center), 'YYYY-MM-DD') AS usage_date,
            att.center                                                     AS center_id,
            c.name                                                         AS center_name
        FROM
            attends att
        JOIN
            booking_resources br
        ON
            br.center = att.booking_resource_center
        AND br.id = att.booking_resource_id
        JOIN
            centers c
        ON
            c.id = att.center
        WHERE
            br.name = 'Towel'
        AND att.start_time BETWEEN :fromDate AND :toDate
        AND att.center IN (:scope) ) t
GROUP BY
    t.center_id,
    t.center_name,
    t.usage_date