-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD')    dato,
    TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI')   AS STARTTIME,
    TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI')    AS STOPTIME,
    'Massage' AS                                           activityname,
	per.CENTER ||'p'|| per.ID AS MEMBERID,
	per.FULLNAME AS PARTICIPANT_NAME,
    c.EXTERNAL_ID                                   AS COST,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END        instructorName,
    ins.ssn AS INSTRUCTOR_SSN
FROM
    BOOKINGS bk
JOIN
    ACTIVITY act
ON
    bk.ACTIVITY = act.ID
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
    Centers C
ON
    c.id = par.center
WHERE
    bk.center IN (:Scope)
AND act.ID IN (8208,
               9009,
               8207,
               30829,
               36627,
               72407,
				91607,
				91407)
AND par.STATE LIKE 'PARTICIPATION'
AND bk.STARTTIME >= :fromDate
AND bk.STARTTIME < :toDate + 3600*1000*24 
AND bk.STATE = 'ACTIVE'
AND st.STATE != 'CANCELLED'
ORDER BY
    bk.STARTTIME
