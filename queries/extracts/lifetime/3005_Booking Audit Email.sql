-- The extract is extracted from Exerp on 2026-02-08
-- Scheduled booking audit to be emailed to Caleb.
WITH
    params AS
    (
        SELECT
            c.id AS CENTER_ID,
            current_date - interval '1 second' AS FROM_DATE,
           current_date + 1 -interval '1 second' AS TO_DATE
        FROM
            centers c
        WHERE
        c.id = 238
        
    )
SELECT
    
    to_char(longtodatec(b.STARTTIME,c.ID), 'YYYY-MM-DD HH24:MI') AS START_DATETIME,b.NAME as BOOKING_NAME,per.fullname                          AS TRAINER,
    a.name                                AS ACTIVITY,
    ag.NAME                               AS ACTIVITY_GROUP,
    
    mem.center || 'p' || mem.id as MEMBER_ID,
mem.firstname||' '||mem.lastname as MEMBER_FULLNAME,
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

--, part.*

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
JOIN    params ON    params.CENTER_ID = c.id
WHERE b.state = 'ACTIVE'
and c.id =238
and longtodateC(b.STARTTIME,238) BETWEEN params.FROM_DATE AND params.TO_DATE
order by START_DATETIME,TRAINER,BOOKING_NAME,MEMBER_FULLNAME


