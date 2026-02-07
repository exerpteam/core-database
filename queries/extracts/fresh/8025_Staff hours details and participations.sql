SELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') b_date,
    TO_CHAR(longtodate(bk.STOPTIME), 'MON') b_month,
    TO_CHAR(longtodate(bk.STOPTIME), 'DY') b_day,
    TO_CHAR(longtodate(bk.STARTTIME), 'HH24:MI') startTime,
    TO_CHAR(longtodate(bk.STOPTIME), 'HH24:MI') endTime,
    act.NAME activityname,
    actgr.NAME activitygroup,
    stfg.NAME staffgroup,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.CENTER || 'p' || ins.ID
    END instructorId,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END instructorName,
    bk.STATE bookingState,
    CASE
        WHEN par.CENTER IS NOT NULL
        THEN par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID
        ELSE NULL
    END participantId,
    CASE
        WHEN par.CENTER IS NOT NULL
        THEN per.FIRSTNAME || ' ' || per.LASTNAME
        ELSE NULL
    END participantName,
    par.STATE participationState,
    par.CANCELATION_REASON
FROM
    BOOKINGS bk
JOIN
    ACTIVITY act
ON
    bk.ACTIVITY = act.ID
JOIN
    ACTIVITY_GROUP actgr
ON
    act.ACTIVITY_GROUP_ID = actgr.ID
JOIN
    ACTIVITY_STAFF_CONFIGURATIONS staffconfig
ON
    staffconfig.ACTIVITY_ID = act.ID
JOIN
    STAFF_GROUPS stfg
ON
    stfg.ID = staffconfig.STAFF_GROUP_ID
LEFT JOIN
    PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
    AND par.BOOKING_ID = bk.ID
LEFT JOIN
    STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
    AND bk.id = st.BOOKING_ID
LEFT JOIN
    PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
    AND st.PERSON_ID = ins.ID
LEFT JOIN
    PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
    AND par.PARTICIPANT_ID = per.ID
LEFT JOIN
    PERSON_STAFF_GROUPS psg
ON
    psg.PERSON_CENTER = ins.CENTER
    AND psg.PERSON_ID = ins.ID
    AND psg.STAFF_GROUP_ID = stfg.ID
    AND psg.SCOPE_TYPE = 'C' AND psg.SCOPE_ID = bk.CENTER
WHERE
    --    bk.center IN (14)
    --    AND longtodate(bk.STARTTIME) >= TO_DATE('2013-05-01', 'YYYY-MM-DD')
    --    AND longtodate(bk.STARTTIME) < TO_DATE('2013-05-31', 'YYYY-MM-DD') + 1
    bk.center IN (:Center)
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + (1000*60*60*24)
ORDER BY
    bk.STARTTIME
