SELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	 TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
	TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI') AS STOPTIME,
   	act.NAME activityname,
    bk.STATE bookingState,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
	par.PARTICIPANT_CENTER,
	c.name,
	c.EXTERNAL_ID as COST,
	par.STATE participationState,

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
		ins.ssn AS INSTRUCTOR_SSN
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
LEFT JOIN PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
    AND st.PERSON_ID = ins.ID
LEFT JOIN PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
    AND par.PARTICIPANT_ID = per.ID

LEFT JOIN Centers C

On c.id = par.center


WHERE

    bk.center IN (:ChosenScope)
    AND act.ID IN (4807, 18818, 18821, 18822, 19407, 18823)


	AND par.STATE LIKE 'PARTICIPATION'
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + 3600*1000*24
    AND bk.STATE = 'ACTIVE'
GROUP BY
	bk.STARTTIME,
	bk.STARTTIME,
	bk.STOPTIME,
   	act.NAME,
    bk.STATE,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID,
	par.PARTICIPANT_CENTER,
	c.name,
	c.EXTERNAL_ID,
	par.STATE,
	ins.CENTER,
	ins.ID,
	ins.FIRSTNAME || ' ' || ins.LASTNAME,
	ins.SSN
ORDER BY
    bk.STARTTIME