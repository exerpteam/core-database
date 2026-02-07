/* Visits Daily Manual */
SELECT
	cen.COUNTRY,
	cen.EXTERNAL_ID												AS Cost,
	cil.CENTER || 'p' || cil.ID 									AS PersonKey,
	per.FIRSTNAME || ' ' || per.LASTNAME 							AS PersonName,

	TO_CHAR(longToDate(cil.CHECKIN_TIME), 'Day') 					AS Weekday,
	TO_CHAR(longToDate(cil.CHECKIN_TIME), 'YYYY-MM-DD')				AS CheckinDate,
	TO_CHAR(TRUNC(longToDate(cil.CHECKIN_TIME), 'HH'), 'HH24') || ' - ' || TO_CHAR(TRUNC(longToDate(cil.CHECKIN_TIME), 'HH') + 1/24, 'HH24') AS Hour,
	CASE
		WHEN cil.CENTER = cil.CHECKIN_CENTER
		THEN 1
		ELSE NULL
	END 															AS LocalVisits,
	CASE
		WHEN cil.CENTER != cil.CHECKIN_CENTER
		THEN 1
		ELSE NULL
	END 															AS GuestVisits,
	1 																AS Visits,
	CASE
		WHEN br.NAME IS NOT NULL THEN BR.NAME
		WHEN act.NAME IS NOT NULL THEN act.NAME
		ELSE 'NONE'
	END 															AS CheckinReason,
	TO_CHAR(longToDate(cil.CHECKIN_TIME), 'YYYY-MM-DD HH24:MI')		AS PersonTime

	
FROM
	CHECKIN_LOG cil

LEFT JOIN CENTERS cen
ON
	cil.CHECKIN_CENTER = cen.ID
LEFT JOIN PERSONS per
ON
	cil.CENTER = per.CENTER
	AND cil.ID = per.ID
----------------------------------------------------------------
-- Checkin reason (Attend/Class)

LEFT JOIN ATTENDS att
ON	
	att.PERSON_CENTER = cil.CENTER
	AND att.PERSON_ID = cil.ID
	AND (att.START_TIME - cil.CHECKIN_TIME) BETWEEN -60000 AND 60000 --one minute +- between checkin and attend is allowed
LEFT JOIN BOOKING_RESOURCES br
ON
	att.BOOKING_RESOURCE_CENTER = br.CENTER
	AND att.BOOKING_RESOURCE_ID = br.ID
LEFT JOIN PARTICIPATIONS par
ON	
	par.PARTICIPANT_CENTER = cil.CENTER
	AND par.PARTICIPANT_ID = cil.ID
	AND (par.SHOWUP_TIME - cil.CHECKIN_TIME) BETWEEN -60000 AND 60000 --one minute +- between checkin and class participation is allowed
LEFT JOIN BOOKINGS bk
ON
	bk.CENTER = par.BOOKING_CENTER
	AND bk.ID = par.BOOKING_ID
LEFT JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID
----------------------------------------------------------------
-----------------------------------------------------------------

WHERE
	cil.CHECKIN_CENTER IN (:ChosenScope)
	AND cil.CHECKIN_TIME >= datetolong(TO_CHAR(:fromdate, 'YYYY-MM-DD HH24:MI'))
	AND cil.CHECKIN_TIME <= datetolong(TO_CHAR(:todate, 'YYYY-MM-DD HH24:MI')) + 86400 * 1000 - 1
--	AND cil.CHECKIN_TIME BETWEEN datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) AND (datetolong(TO_CHAR(TRUNC(exerpsysdate() -1), 'YYYY-MM-DD HH24:MI')) + 86399 * 1000)
	
ORDER BY
	cil.CHECKIN_CENTER,
	cil.CHECKIN_TIME