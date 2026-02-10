-- The extract is extracted from Exerp on 2026-02-08
-- This report shows persons who have checked in, but have not been tracked for their booking given day.
WITH
    params AS
    (
        SELECT
            cen.id AS CENTER_ID,
            --datetolongc(TO_CHAR(to_date('2020-01-19', 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), cen.id) AS FROM_DATE,
            --datetolongc(TO_CHAR(to_date('2020-01-21', 'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), cen.id) + (24*3600*1000) - 1 AS TO_DATE
            datetolongTZ(TO_CHAR(to_date($$from_date$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),cen.time_zone) AS FROM_DATE,
            datetolongTZ(TO_CHAR(to_date($$to_date$$,'yyyy-mm-dd'),'YYYY-MM-DD HH24:MI:SS' ),cen.time_zone) + (24*3600*1000) - 1 AS TO_DATE,
datetolongTZ(to_char(now(),'YYYY-MM-DD HH24:MI:SS'),cen.time_zone) as time_now
        FROM
            centers cen
        WHERE
            cen.id IN ($$scope$$)
    )
    
SELECT
    to_char(longtodatec(chk.checkin_time,chk.checkin_center), 'YYYY-MM-DD HH24:MI') AS CHECKIN_DATETIME,
    to_char(longtodatec(b.STARTTIME,c.ID), 'YYYY-MM-DD HH24:MI') AS START_DATETIME,
    b.NAME as BOOKING_NAME,per.fullname                          AS TRAINER,
    a.name                                AS ACTIVITY,
    ag.NAME                               AS ACTIVITY_GROUP,
    
    mem.center || 'p' || mem.id as MEMBER_ID,
mem.external_id,
mem.fullname as MEMBER_FULLNAME,
    part.state as PARTICIPATION_STATE,
    part.cancelation_reason as CANCELLATION_REASON,
    
    CASE
        WHEN part.state = 'BOOKED'
        THEN 'N/A'
        WHEN part.state = 'PARTICIPATION'
        THEN 'Show-up'
        WHEN part.state = 'CANCELLED' AND part.cancelation_reason = 'NO_SHOW'
        THEN 'No-Show'
        WHEN part.state = 'CANCELLED' AND part.cancelation_reason = 'BOOKING' 
        THEN 'Booking cancelled'
        WHEN part.state = 'CANCELLED' AND part.cancelation_reason = 'NO_PRIVILEGE' 
        THEN 'Cancelled (No privilege)'
        WHEN part.state = 'CANCELLED' AND part.cancelation_reason in ('USER', 'CENTER') 
        THEN 'Cancelled by staff or user'
        ELSE 'Other'
    END AS SHOWUP_STATUS


FROM
    PARTICIPATIONS part
JOIN PERSONS mem on mem.center = part.participant_center and mem.id = part.participant_id
JOIN
    BOOKINGS b
ON
    b.center = part.BOOKING_CENTER
AND b.id = part.BOOKING_ID
JOIN
    ACTIVITY a
ON
    a.id = b.ACTIVITY
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
    centers c
ON
    c.id = b.center
JOIN
    ACTIVITY_GROUP ag
ON
    ag.id = a.ACTIVITY_GROUP_ID
JOIN
    params
ON
    params.CENTER_ID = c.id
    
JOIN checkins chk
        ON 
                chk.person_center = part.participant_center
                AND chk.person_id = part.participant_id
                AND chk.checkin_center = part.center
                AND chk.checkin_time > part.start_time - (3*60*60*1000)
                AND chk.checkin_time < part.start_time    

where b.state = 'ACTIVE'
and b.STARTTIME BETWEEN params.FROM_DATE AND params.TO_DATE
and part.state not in ('PARTICIPATION')
and b.starttime <= time_now
order by START_DATETIME,TRAINER,BOOKING_NAME,MEMBER_FULLNAME
--https://clublead.atlassian.net/browse/ST-4955