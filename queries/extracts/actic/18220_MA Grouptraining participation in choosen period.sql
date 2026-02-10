-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	 TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
	TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI') AS STOPTIME,
   	act.NAME activityname,
    bk.STATE bookingState,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
	par.ON_WAITING_LIST,
	par.SHOWUP_TIME,


	par.CREATION_BY_CENTER || 'p' || par.CREATION_BY_ID CreatedBY,
    p.FIRSTNAME || ' ' || p.LASTNAME CreatedByName,
	par.PARTICIPANT_CENTER,
	c.EXTERNAL_ID as COST,
	par.STATE participationState,

			
	

    

CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.CENTER || 'p' || ins.ID
    END instructorId
    --CASE
        --WHEN ins.CENTER IS NULL
        --THEN NULL
        --ELSE p.FIRSTNAME || ' ' || p.LASTNAME
    --END instructorName
    
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

LEFT JOIN PERSONS p
ON
    par.CREATION_BY_CENTER = p.CENTER
    AND par.CREATION_BY_ID = p.ID


LEFT JOIN Centers C

On c.id = par.center


WHERE

    bk.center IN (:ChosenScope)
    --AND act.ACTIVITY_TYPE = '2'


	--AND par.STATE IN (PARTICIPATIONSTATE)
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + 3600*1000*24
    AND bk.STATE = 'ACTIVE'
	AND st.STATE != 'CANCELLED'



ORDER BY
    bk.STARTTIME
