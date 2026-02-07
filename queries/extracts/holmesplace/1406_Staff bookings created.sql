
SELECT
    b.CENTER booking_center,
    c.name,
    TO_CHAR(longToDate(b.STARTTIME),'YYYY-MM-DD HH24:MI')        booking_start,
    TO_CHAR(longToDate(b.STOPTIME),'YYYY-MM-DD HH24:MI')         booking_stop,
    TO_CHAR(longToDate(b.CREATION_TIME),'YYYY-MM-DD HH24:MI')    booking_creation_time,
    TO_CHAR(longToDate(b.CANCELATION_TIME),'YYYY-MM-DD HH24:MI') booking_cancellation_time,
    b.STATE,
    REPLACE(b.COMENT,';','@@semicolon@@')            "COMMENT",
    REPLACE(a.NAME,';','@@semicolon@@')              "ACTIVITY_NAME",
    b.OWNER_CENTER || 'p' || b.OWNER_ID              cust_id,
    REPLACE(cust.FULLNAME,';','@@semicolon@@')       Member,
    REPLACE(staff.FULLNAME,';','@@semicolon@@')      STAFF,
    REPLACE(creator.FULLNAME,';','@@semicolon@@')    booking_creator,
    par.state                                     AS participation,
    a.ACTIVITY_TYPE
FROM
    BOOKINGS b
JOIN
    ACTIVITY a
ON
    a.ID = b.ACTIVITY
JOIN
    PARTICIPATIONS par
ON
    par.BOOKING_CENTER = b.CENTER
    AND par.BOOKING_ID = b.ID
LEFT JOIN
    PERSONS cust
ON
    par.PARTICIPANT_CENTER = cust.CENTER
    AND par.PARTICIPANT_ID = cust.ID
LEFT JOIN
    centers c
ON
    b.CENTER = c.id
LEFT JOIN
    STAFF_USAGE su
ON
    su.BOOKING_CENTER = b.CENTER
    AND su.BOOKING_ID = b.ID
LEFT JOIN
    PERSONS staff
ON
    staff.CENTER = su.PERSON_CENTER
    AND staff.ID = su.PERSON_ID
LEFT JOIN
    PERSONS creator
ON
    creator.CENTER = b.creator_center
    AND creator.ID = b.creator_id
WHERE
    a.ACTIVITY_TYPE >1
    AND b.center IN ($$scope$$)
    AND b.CREATION_TIME BETWEEN $$createStart$$ AND (
        $$createEnd$$ + 86400 * 1000 -1)
    AND b.STATE = 'ACTIVE'
ORDER BY
    b.STARTTIME ASC
