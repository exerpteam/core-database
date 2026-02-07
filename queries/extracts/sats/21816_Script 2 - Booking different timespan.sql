SELECT
    p.center,
    p.PARTICIPANT_CENTER || 'p' || p.PARTICIPANT_ID pid,
    longToDate(p.START_TIME) first_booking_start,
    longToDate(p.STOP_TIME) first_booking_end,
    p2.center,
    longToDate(p2.START_TIME) second_booking_start,
    longToDate(p2.STOP_TIME) second_booking_end
FROM
    SATS.PARTICIPATIONS p
JOIN SATS.PARTICIPATIONS p2
ON
    p2.PARTICIPANT_CENTER = p.PARTICIPANT_CENTER
    AND p2.PARTICIPANT_ID = p.PARTICIPANT_ID
    AND p2.START_TIME BETWEEN p.STOP_TIME AND
    (
        p.STOP_TIME + 1000*60*60*:hoursBetween
    )
    AND p2.CENTER != p.CENTER
    AND p.STATE = 'BOOKED'
    AND p2.STATE = 'BOOKED'
WHERE
    p.START_TIME between :parStart and :parEnd
    AND p.CENTER in (:scope)