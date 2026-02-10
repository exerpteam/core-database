-- The extract is extracted from Exerp on 2026-02-08
--  

SELECT
 b.CENTER booking_center,
c.name,
 /* TO_CHAR(b.ID) booking_id, */
 TO_CHAR(longToDate(b.STARTTIME),'YYYY-MM-DD HH24:MI') booking_start,
 TO_CHAR(longToDate(b.STOPTIME),'YYYY-MM-DD HH24:MI') booking_stop,
 TO_CHAR(longToDate(b.CREATION_TIME),'YYYY-MM-DD HH24:MI')
 booking_creation_time,
 TO_CHAR(longToDate(b.CANCELATION_TIME),'YYYY-MM-DD HH24:MI')
 booking_cancellation_time,
 b.STATE,
 REPLACE(b.COMENT,';','@@semicolon@@') "COMMENT",
 REPLACE(a.NAME,';','@@semicolon@@') "ACTIVITY_NAME",
 b.OWNER_CENTER || 'p' || b.OWNER_ID cust_id,
 REPLACE(cust.FULLNAME,';','@@semicolon@@') Member,
 REPLACE(staff.FULLNAME,';','@@semicolon@@') STAFF,
par.state as participation,
 a.ACTIVITY_TYPE
 FROM
 BOOKINGS b
 JOIN ACTIVITY a
 ON
 a.ID = b.ACTIVITY 

LEFT JOIN PERSONS cust
 ON
 cust.CENTER = b.OWNER_CENTER
 AND cust.ID = b.OWNER_ID
 join PARTICIPATIONS par on par.BOOKING_CENTER = b.CENTER and par.BOOKING_ID
 = b.ID and par.PARTICIPANT_CENTER = cust.CENTER and par.PARTICIPANT_ID =
 cust.ID
 LEFT JOIN centers c
 ON
 b.CENTER = c.id
 LEFT JOIN STAFF_USAGE su
 ON
 su.BOOKING_CENTER = b.CENTER
 AND su.BOOKING_ID = b.ID
 LEFT JOIN PERSONS staff
 ON
 staff.CENTER = su.PERSON_CENTER
 AND staff.ID = su.PERSON_ID
 WHERE
 a.ACTIVITY_TYPE >1 
 AND cust.center IN (:scope)
 and b.STARTTIME between :bookStart and (:bookEnd + 86400 * 1000 -1)
 AND b.STATE = 'ACTIVE'
/* and par.state ='PARTICIPATION' */
 ORDER BY
b.STARTTIME
/* b.CREATION_TIME */ ASC 