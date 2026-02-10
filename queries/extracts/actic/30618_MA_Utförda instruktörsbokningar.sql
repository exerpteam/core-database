-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
c.id,
	bk.id,
	per.fullname,
	c.name,
	pm.txtvalue AS phonemobile,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	 TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
	TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI') AS STOPTIME,
   	bk.NAME activityname,
	act.id,
	c.EXTERNAL_ID as COST,
	par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
	par.STATE,
	TO_CHAR (longtodate(par.showup_time), 'YYYY-MM-DD') AS Showup,
	

    


    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END instructorName
    
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

left join person_ext_attrs pm 
on 
	pm.personcenter = per.center 
	and pm.personid = per.id 
	and pm.name = '_eClub_PhoneSMS' 


WHERE

    bk.center IN (:Scope)
    
AND act.ACTIVITY_TYPE = 4








	AND par.STATE LIKE 'PARTICIPATION'
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + 3600*1000*24
	--AND bk.STARTTIME >= datetolong(TO_CHAR(TRUNC(current_timestamp -1), 'YYYY-MM-DD HH24:MI')) -- yesterday at midnight
	--AND bk.STARTTIME < datetolong(TO_CHAR(TRUNC(current_timestamp -1), 'YYYY-MM-DD HH24:MI')) + 86399*1000 -- yesterday at midnight +24 hours --in ms
    AND bk.STATE = 'ACTIVE'
	AND st.STATE != 'CANCELLED'

ORDER BY
    bk.STARTTIME
	
