WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id                                                                                                                  AS CENTER_ID,
            datetolongtz(TO_CHAR(TRUNC(TO_DATE(getcentertime(c.id), 'YYYY-MM-dd HH24:MI')), 'YYYY-MM-dd HH24:MI'), c.time_zone) AS StartDateLong,
            datetolongtz(TO_CHAR(TRUNC(TO_DATE(getcentertime(c.id), 'YYYY-MM-dd HH24:MI')+6), 'YYYY-MM-dd HH24:MI'), c.time_zone)-1 AS EndDateLong
        FROM
            centers c
        WHERE
            c.id = :center
    )

SELECT
	per.CENTER AS CENTER,
	per.ID AS ID,
    per.center || 'p' || per.id AS "PERSONKEY"
FROM PERSONS per 
JOIN
    params
ON
    params.CENTER_ID = per.CENTER
JOIN PARTICIPATIONS par ON
	par.PARTICIPANT_CENTER = per.CENTER
	AND par.PARTICIPANT_ID = per.ID
JOIN BOOKINGS bk ON
	par.BOOKING_CENTER = bk.CENTER
	AND par.BOOKING_ID = bk.ID
JOIN ACTIVITY act ON
	bk.ACTIVITY = act.ID
JOIN CENTERS c ON
	par.CENTER = c.ID
WHERE 
	par.STATE IN ('BOOKED')
	AND bk.STARTTIME >= params.StartDateLong
	AND bk.STARTTIME <= params.EndDateLong
	AND act.ACTIVITY_TYPE = 9