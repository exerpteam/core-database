-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            -- March  - Corona Virus
            
            datetolongc(TO_CHAR(to_date($$start_date$$, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'), c.id) AS fromDateCorona,
            datetolongc(TO_CHAR(to_date($$to_date$$, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'), c.id) + (24*3600*1000) - 1 AS toDateCorona,
            c.id AS centerid,
            C.country AS c_country
        FROM
            centers c
        WHERE c.id IN ($$scope$$)
    )
SELECT
    B.NAME,
    per.fullname                                  AS TRAINER,
    pa.participant_center||'p'||pa.participant_id AS personid,
    mem.external_id,
    mem.fullname                                                      AS MEMBER_FULLNAME,
    b.center ||'book'||b.id                                                         AS bookingid,
    TO_CHAR(longtodatec(chk.checkin_time,chk.checkin_center), 'YYYY-MM-DD HH24:MI') AS
                                                                    CHECKIN_DATETIME,
    TO_CHAR(longtodatec(b.STARTTIME,b.center), 'YYYY-MM-DD HH24:MI') AS BOOKING_START_DATETIME,
    (
        CASE
            WHEN pa.state = 'BOOKED'
            THEN 'N/A'
            WHEN pa.state = 'PARTICIPATION'
            THEN 'Show-up'
            WHEN pa.state = 'CANCELLED'
            AND pa.cancelation_reason = 'NO_SHOW'
            THEN 'No-Show'
            WHEN pa.state = 'CANCELLED'
            AND pa.cancelation_reason = 'BOOKING'
            THEN 'Booking cancelled'
            WHEN pa.state = 'CANCELLED'
            AND pa.cancelation_reason = 'NO_PRIVILEGE'
            THEN 'Cancelled (No privilege)'
            WHEN pa.state = 'CANCELLED'
            AND pa.cancelation_reason IN ('USER',
                                            'CENTER')
            THEN 'Cancelled by staff or user'
            ELSE 'Other'
        END) AS SHOWUP_STATUS,
    pu.misuse_state as "Privilege Usage State", 
    pu.STATE,
    B.state AS booking_state,
    b.cancellation_reason
FROM
    BOOKINGS B
JOIN
    PARAMS
ON
    CENTERID = B.CENTER
LEFT JOIN
    STAFF_USAGE su
ON
    su.BOOKING_CENTER = b.center
AND su.BOOKING_ID = b.id
AND su.state = 'ACTIVE'
LEFT JOIN
    persons per
ON
    per.CENTER = su.PERSON_CENTER
AND per.ID = su.PERSON_ID
JOIN
    participations PA
ON
    B.CENTER = PA.booking_center
AND B.ID =PA.booking_id
AND PA.STATE <>'PARTICIPATION'
LEFT JOIN
    PRIVILEGE_USAGES pu
ON
    pu.TARGET_CENTER = pa.CENTER
AND pu.TARGET_ID = pa.ID
JOIN
    ACTIVITY A
ON
    A.ID = B.activity
JOIN
    participation_configurations pc
ON
    a.id = pc.activity_id
JOIN PERSONS mem ON mem.center = pa.participant_center AND mem.id = pa.participant_id
JOIN
    booking_privilege_groups bpg
ON
    pc.access_group_id = bpg.id
AND bpg.name = 'Group Fitness Sanction'
JOIN
    checkins chk
ON
    chk.person_center = pa.participant_center
AND chk.person_id = pa.participant_id
AND chk.checkin_center = pa.center
AND chk.checkin_time > pa.start_time - (3*60*60*1000)
AND chk.checkin_time < pa.start_time
WHERE
    B.starttime BETWEEN fromDateCorona AND toDateCorona
AND longtodateC(b.starttime,b.center) <= now()
AND pu.misuse_state IN ('MISUSED', 'PUNISHED')