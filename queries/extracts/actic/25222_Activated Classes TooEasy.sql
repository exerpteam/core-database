-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Creator: Mikael Ahlberg
* Purpose: Show information of activated classes for a given period and scope.
* Usage: Used by HR for information of classes.
*/
SELECT
	TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI') AS STARTTIME,
	TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI') AS STOPTIME,
   	act.NAME activityname,
	c.EXTERNAL_ID as Cost,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END instructorName,
	ins.ssn

    
FROM
    BOOKINGS bk
JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID

LEFT JOIN STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
    AND bk.id = st.BOOKING_ID
LEFT JOIN PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
    AND st.PERSON_ID = ins.ID
 
LEFT JOIN Centers c
on
BK.center = c.id 




WHERE

    bk.center IN (:ChosenScope)
    AND act.ACTIVITY_TYPE = '2' -- Only include GroupTraining


   	AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + 3600*1000*24


    AND bk.STATE = 'ACTIVE'
	AND st.STATE != 'CANCELLED'



ORDER BY
    bk.STARTTIME