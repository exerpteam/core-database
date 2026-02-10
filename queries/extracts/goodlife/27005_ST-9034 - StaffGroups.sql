-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-9034
WITH
    PARAMS AS
    (
        SELECT
            datetolongC(TO_CHAR(to_date(getcentertime(c.id),'YYYY-MM-DD HH24:MI:SS')+8,
            'YYYY-MM-DD HH24:MI:SS'),c.ID) AS today,
            c.ID                           AS centerId
        FROM
            centers c
    )
    ,
    eligibles AS
    (
        SELECT DISTINCT
            a.ID AS ActivityID,
            b.CENTER,
            su.person_center,
            su.person_id
        FROM
            goodlife.activity a
        JOIN
            goodlife.bookings b
        ON
            a.id = b.activity
        JOIN
            PARAMS
        ON
            params.centerId = b.center
        JOIN
            goodlife.participations p
        ON
            p.booking_center = b.center
        AND p.booking_id = p.id
        JOIN
            goodlife.staff_usage su
        ON
            su.booking_center = b.center
        AND su.booking_id = b.id
        WHERE
            b.activity IN (4201,4207,6801,4211,5201,6803,4219)
        AND b.starttime > params.today
        AND b.state != 'CANCELLED'
        AND p.state != 'CANCELLED'
        AND su.state != 'CANCELLED'
    )
SELECT
    e.ActivityID,
    e.center                              AS BookingCenter,
    e.person_center || 'p' || e.person_id AS StaffId,
    (
        CASE
            WHEN psg.person_center IS NOT NULL
            THEN 'YES'
            ELSE 'NO'
        END)      Has_Staff_Group,
    'Yin Yoga' AS Staff_Group_Needed
FROM
    eligibles e
LEFT JOIN
    goodlife.person_staff_groups psg
ON
    psg.person_center = e.person_center
AND psg.person_id = e.person_id
AND psg.scope_id = e.center
AND psg.staff_group_id = 3001 --Yin Yoga
WHERE
    e.ActivityID = 4207
UNION
SELECT
    e.ActivityID,
    e.center                              AS BookingCenter,
    e.person_center || 'p' || e.person_id AS StaffId,
    (
        CASE
            WHEN psg.person_center IS NOT NULL
            THEN 'YES'
            ELSE 'NO'
        END)     Has_Staff_Group,
    'Pilates' AS Staff_Group_Needed
FROM
    eligibles e
LEFT JOIN
    goodlife.person_staff_groups psg
ON
    psg.person_center = e.person_center
AND psg.person_id = e.person_id
AND psg.scope_id = e.center
AND psg.staff_group_id = 230 --Pilates
WHERE
    e.ActivityID = 4211
UNION
SELECT
    e.ActivityID,
    e.center                              AS BookingCenter,
    e.person_center || 'p' || e.person_id AS StaffId,
    (
        CASE
            WHEN psg.person_center IS NOT NULL
            THEN 'YES'
            ELSE 'NO'
        END)                     Has_Staff_Group,
    'Mind Body Certification' AS Staff_Group_Needed
FROM
    eligibles e
LEFT JOIN
    goodlife.person_staff_groups psg
ON
    psg.person_center = e.person_center
AND psg.person_id = e.person_id
AND psg.scope_id = e.center
AND psg.staff_group_id = 1201 --Mind Body Certification
WHERE
    e.ActivityID = 4219
UNION
SELECT
    e.ActivityID,
    e.center                              AS BookingCenter,
    e.person_center || 'p' || e.person_id AS StaffId,
    (
        CASE
            WHEN psg.person_center IS NOT NULL
            THEN 'YES'
            ELSE 'NO'
        END)        Has_Staff_Group,
    'Meditation' AS Staff_Group_Needed
FROM
    eligibles e
LEFT JOIN
    goodlife.person_staff_groups psg
ON
    psg.person_center = e.person_center
AND psg.person_id = e.person_id
AND psg.scope_id = e.center
AND psg.staff_group_id = 2401 --Meditation
WHERE
    e.ActivityID = 6801