WITH
    PARAMS AS materialized
    (
        SELECT
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS fromDate,
                datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
    --bk.id,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD')    dato,
    TO_CHAR (longtodate(bk.STARTTIME), 'HH24:MI')   AS STARTTIME,
    TO_CHAR (longtodate(bk.STOPTIME), 'HH24:MI')    AS STOPTIME,
	'Massage' AS                                           activityname,
    --act.NAME                                           activityname,
    c.EXTERNAL_ID                                   AS COST,
    --par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END        instructorName,
    ins.ssn AS INSTRUCTOR_SSN
FROM
    BOOKINGS bk
JOIN	
	PARAMS params ON params.CenterID = bk.CENTER
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
				91407
)
AND par.STATE LIKE 'PARTICIPATION'
    --AND bk.STARTTIME >= FromDate
    --AND bk.STARTTIME < ToDate + 3600*1000*24
--AND bk.STARTTIME >= datetolong(TO_CHAR(TRUNC(current_timestamp -1), 'YYYY-MM-DD HH24:MI')) -- yesterday at
AND bk.STARTTIME >= params.fromDate
    -- midnight
--AND bk.STARTTIME < datetolong(TO_CHAR(TRUNC(current_timestamp -1), 'YYYY-MM-DD HH24:MI')) + 86399*1000 --
AND bk.STARTTIME < params.toDate
    -- yesterday at midnight +24 hours in ms
AND bk.STATE = 'ACTIVE'
AND st.STATE != 'CANCELLED'
ORDER BY
    bk.STARTTIME
