-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	 TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
	TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI') AS STOPTIME,
   	act.NAME activityname,
	c.EXTERNAL_ID as COST,
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


    bk.center IN (9226)
 
    

AND act.ID IN (4807,
               18818,
               18821,
               18822,
               19407,
               18823,
               24207,
               34071,
               34063,
               34066,
               34069,
				34065,
				34068


		)





	--AND par.STATE LIKE 'PARTICIPATION'
    AND bk.STARTTIME >= 1630454400000
    AND bk.STARTTIME < 1638316800000 --First December 2021
    AND bk.STATE = 'ACTIVE'
	AND st.STATE != 'CANCELLED'

ORDER BY
    bk.STARTTIME