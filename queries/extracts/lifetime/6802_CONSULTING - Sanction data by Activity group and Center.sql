-- The extract is extracted from Exerp on 2026-02-08
-- ES-22717 Exerp internal sanction manangement
--Data script
SELECT
ag.id   AS "ActivityGroupID",
    ag.name AS "ActivityGroup",
bk.center as "BookingCenter",
    pu.person_center||'p'||pu.person_id AS        "Member",
    bk.center||'bk'||bk.id              AS        "Booking",
    bk.center                           AS        "BookingCenter",
    TO_CHAR(longtodateTZ(bk.starttime, 'America/Toronto'), 'YYYY-MM-DD HH24:MI:SS') "BookingStarttimeET",
    bk.name         AS                                    "BookingName",
    pu.state        AS                                    "PuParticipationStatus",
    pu.misuse_state AS                                    "PuMisuseStatus",
    CASE
        WHEN act.activity_type = 2
        THEN 'Class'
        WHEN act.activity_type = 1
        THEN 'General'
        WHEN act.activity_type = 3
        THEN 'Resource booking'
        ELSE 'Other'
    END     AS "ActivityType"
    -- ,*
FROM
    privilege_usages pu
JOIN
    participations pa
ON
    pu.target_service = 'Participation'
AND pu.target_center = pa.center
AND pu.target_id = pa.id
LEFT JOIN
    bookings bk
ON
    bk.center = pa.booking_center
AND bk.id = pa.booking_id
LEFT JOIN
    activity act
ON
    bk.activity = act.id
LEFT JOIN
    activity_group ag
ON
    act.activity_group_id = ag.id
WHERE
    pu.privilege_type = 'BOOKING'
AND pu.state = 'CANCELLED'
AND pu.misuse_state NOT IN ('NOT_PROCESSED',
                            'NOT_MISUSABLE')
AND pu.last_modified > (extract(epoch FROM CURRENT_TIMESTAMP)*1000 - :offset*24*60*60*1000) --for extract
--AND pu.target_start_time > (extract(epoch FROM CURRENT_TIMESTAMP)*1000 - ${offset}$*24*60*60*1000) -- for DBvis
--AND pu.target_start_time > (extract(epoch FROM CURRENT_TIMESTAMP)*1000 - 1*24*60*60*1000) -- Set offset day manually

AND bk.center = :center
;