-- The extract is extracted from Exerp on 2026-02-08
-- 
SELECT
    b.center||'bk'||b.id         AS bookingid,
    longtodateC(B.starttime,990) AS start_time,
    acs.maximum_staffs           AS config_max_staff,
    COUNT(su.*) ,
    ag.name AS activitygroup ,
    b.name  AS booking_name,
    longtodateC(b.creation_time,990) as creation_time
FROM
    bookings b
JOIN
    goodlife.staff_usage su
ON
    su.booking_center = b.center
AND su.booking_id = b.id
JOIN
    activity a
ON
    b.activity = a.id
JOIN
    goodlife.activity_group ag
ON
    a.activity_group_id = ag.id
JOIN
    activity_staff_configurations acs
ON
    acs.activity_id = a.id
WHERE
    b.STARTTIME >1573154904000
AND su.state = 'ACTIVE'
AND acs.maximum_staffs =1
GROUP BY
    bookingid,
    B.starttime,
    config_max_staff,
    activitygroup,
    booking_name,creation_time
HAVING
    COUNT(su.*) >1
ORDER BY
    start_time ASC