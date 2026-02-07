/*
* Extrakt to fetch upcoming bookings (two hours from now).
* These should be sent as reminders in ActicApp.
* Creator: Henrik Håkanson
*/ 
SELECT
	par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID AS "MEMBER_ID",
	per.FULLNAME AS "MEMBER_NAME",
	par.STATE AS "PARTICIPATION_STATE",
	bk.NAME AS "CLASS_NAME",
	TO_CHAR(longtodate(bk.STARTTIME),'YYYY-MM-DD HH24:MI') AS "STARTTIME",
	twiikid.TXTVALUE AS "TWIIKID",
	c.COUNTRY AS "COUNTRY",
	bk.CENTER||'p'||bk.ID AS "COMPOUNDID"
FROM PARTICIPATIONS par 
JOIN PERSONS per ON
	par.PARTICIPANT_CENTER = per.CENTER
	AND par.PARTICIPANT_ID = per.ID
LEFT JOIN PERSON_EXT_ATTRS twiikid
ON
    twiikid.PERSONCENTER = per.CENTER
AND twiikid.PERSONID = per.ID
AND twiikid.NAME = 'TWIIKID'
JOIN BOOKINGS bk ON
	par.BOOKING_CENTER = bk.CENTER
	AND par.BOOKING_ID = bk.ID
JOIN ACTIVITY act ON
	bk.ACTIVITY = act.ID
JOIN CENTERS c ON
	par.CENTER = c.ID
WHERE 
	par.STATE IN ('BOOKED')
	AND bk.STARTTIME >= datetolong(:startDate)
	AND bk.STARTTIME < datetolong(:endDate)
	AND twiikid.TXTVALUE IS NOT NULL
	AND act.NAME NOT LIKE ('Internt%')
	AND c.COUNTRY = :country
	AND par.ON_WAITING_LIST = 0
