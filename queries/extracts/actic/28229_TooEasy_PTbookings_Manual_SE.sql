-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
	bk.id,
	act.id,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	 TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
	TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI') AS STOPTIME,
   	act.NAME activityname,
	c.EXTERNAL_ID as COST,
	par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
	par.STATE,
	par.CANCELATION_REASON,
	st.STATE,

	TO_CHAR (longtodate(par.showup_time), 'YYYY-MM-DD') AS Showup,
	

    


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


    bk.center IN (:Scope)
 
    

AND act.ID IN (4807, -- Personlig Träning (60 min)
               18818, -- INSTRUKTæR AG
               18821, -- StartPT (tidigare medlem)
               18822, -- Träningsstart 1 PT
               19407, -- Personlig Träning DUO
               18823, -- Träningsstart 1 PT
               24207, -- Personlig träning (30 min)
               34071, -- Träningsuppföljning PT
               34066, -- Treningsstart 2 PT
               34069, -- Träningsuppföljning PT
	           34068, --Träningsstart 2 PT
			   64613, -- PT Get started 60 min
			   62212, -- Simskola Privat 30 min
			   59807, -- Simskola Privat barn 30 min
			   87207, -- PT Online 15 min	
			   86208, -- Simskola Privat 60 min
			   88230, -- Crawl Privat 30 min
			   88209 -- Crawl Privat 60 min
		)





	AND (
		(par.STATE LIKE 'PARTICIPATION')
		OR (par.STATE = 'CANCELLED' AND par.CANCELATION_REASON = 'NO_SHOW')
	)
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + 3600*1000*24
	--AND bk.STARTTIME >= datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) -- yesterday at midnight
	--AND bk.STARTTIME < datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) + 86399*1000 -- yesterday at midnight +24 hours --in ms
    AND bk.STATE = 'ACTIVE'
	AND st.STATE != 'CANCELLED'

ORDER BY
    bk.STARTTIME