SELECT
	bk.center,
	bk.activity,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	 TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
	TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI') AS STOPTIME,
   	act.NAME activityname,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId

FROM
    BOOKINGS bk
JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID
LEFT JOIN PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
    AND par.BOOKING_ID = bk.ID

LEFT JOIN STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
    AND bk.id = st.BOOKING_ID

LEFT JOIN PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
    AND par.PARTICIPANT_ID = per.ID


WHERE

    bk.center IN (:ChosenScope)


	 AND par.STATE = 'PARTICIPATION'
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + 3600*1000*24
    AND bk.STATE = 'ACTIVE'
	AND st.STATE != 'CANCELLED'



ORDER BY
    bk.STARTTIME