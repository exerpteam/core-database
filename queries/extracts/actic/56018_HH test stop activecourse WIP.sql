/*
* Extrakt to fetch upcoming bookings (two hours from now).
* These should be sent as reminders in ActicApp.
* Creator: Henrik Håkanson
*/ 

WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id                                                                                                                  AS CENTER_ID,
            datetolongtz(TO_CHAR(TRUNC(TO_DATE(getcentertime(c.id), 'YYYY-MM-dd HH24:MI')), 'YYYY-MM-dd HH24:MI'), c.time_zone) AS CutDate
        FROM
            centers c
        WHERE
            c.id = :center
    )
SELECT 
	p.CENTER,
	p.ID,
	activecourse.TXTVALUE
FROM PERSONS p
JOIN PARTICIPATIONS par ON
	par.PARTICIPANT_CENTER = p.CENTER
	AND par.PARTICIPANT_ID = p.ID
JOIN BOOKINGS b ON
	par.BOOKING_CENTER = b.CENTER
	AND par.BOOKING_ID = b.ID
JOIN ACTIVITY act ON
	b.ACTIVITY = act.ID
JOIN PERSON_EXT_ATTRS activecourse ON
	activecourse.PERSONCENTER = p.CENTER
	AND activecourse.PERSONID = p.ID
	AND activecourse.NAME = 'ACTIVECOURSE'
JOIN params ON
   	params.CENTER_ID = b.CENTER

WHERE 
	act.ACTIVITY_TYPE = 9
	AND b.BOOKING_PROGRAM_ID IS NOT NULL
	AND	activecourse.TXTVALUE = 'true'
	AND p.BOOKING_PROGRAM_ID NOT IN(
		SELECT
			b.BOOKING_PROGRAM_ID
		FROM BOOKINGS b
		JOIN
    		params
		ON
    		params.CENTER_ID = b.CENTER
		JOIN ACTIVITY act ON
			b.ACTIVITY = act.ID
		WHERE 
			act.ACTIVITY_TYPE = 9
			AND b.BOOKING_PROGRAM_ID IS NOT NULL
			AND b.STARTTIME > params.CutDate
		GROUP BY b.BOOKING_PROGRAM_ID
	)
GROUP BY 
	p.CENTER,
	p.ID,
	activecourse.TXTVALUE
