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
ON
BK.center = c.id 




WHERE
	bk.center in (:scope)
	AND act.ID NOT IN (46807, 53407)
	AND (
		ins.FIRSTNAME NOT LIKE('Actic%')
		AND ins.FIRSTNAME NOT LIKE('ACTIC%')
		AND ins.FIRSTNAME NOT LIKE('Schwimmbad%')
		AND ins.FIRSTNAME NOT LIKE('Exerp%')
		AND ins.FIRSTNAME NOT LIKE('Schwimmen%')
		AND (
			ins.FIRSTNAME NOT LIKE('Trainer%')
			AND ins.LASTNAME NOT LIKE('Sauna%')
		)
	)
	AND act.ACTIVITY_TYPE = '2'
	AND bk.STARTTIME >= datetolong(TO_CHAR(TRUNC(current_timestamp +interval '1 day'*:dateOffset), 'YYYY-MM-DD HH24:MI')) -- yesterday at midnight
	AND bk.STARTTIME < datetolong(TO_CHAR(TRUNC(current_timestamp +interval '1 day'*:dateOffset2), 'YYYY-MM-DD HH24:MI')) + 86399*1000 -- yesterday at midnight +24 hours --in ms



    AND bk.STATE = 'ACTIVE'
	AND st.STATE != 'CANCELLED'



ORDER BY
    bk.STARTTIME
