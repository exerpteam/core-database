-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) - 86399000 AS fromDate,
                datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
	TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD')    dato,
    TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI')   AS STARTTIME,
    TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI')    AS STOPTIME,
    bk.NAME                                           activityname,
    c.EXTERNAL_ID                                   AS COST,
    
	CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END        instructorName,
    ins.ssn AS INSTRUCTOR_SSN
FROM
    BOOKINGS bk
JOIN PARAMS params ON params.CenterID = bk.CENTER
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
    bk.center IN (:scope)
	and c.country IN('DE','AU')
AND act.ACTIVITY_GROUP_ID IN (2203)

AND par.STATE LIKE 'PARTICIPATION'
AND bk.STARTTIME >= params.fromDate -- yesterday at midnight
AND bk.STARTTIME < params.toDate --
    -- yesterday at midnight +24 hours --in ms
AND bk.STATE = 'ACTIVE'
AND st.STATE != 'CANCELLED'
ORDER BY
    bk.STARTTIME
