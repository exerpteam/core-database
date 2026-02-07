/*
 * Trialbookings in specified period MANUAL
 */
-- TODO
-- Make sure that it show historical persontype in case of period is way back
-- Add subscription and paymenttype. This way we can follow when follow-ups is in relation to subcription startdate

SELECT
	CASE
		WHEN per.CENTER IS NULL THEN cen_ins.COUNTRY
		ELSE cen.COUNTRY
	END AS Country,
	CASE
		WHEN per.CENTER IS NULL THEN cen_ins.EXTERNAL_ID
		ELSE cen.EXTERNAL_ID
	END AS Cost,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	act.ID AS ActivityID,
   	act.NAME activityname,
    bk.STATE bookingState,
  	CASE
		WHEN per.CENTER IS NULL THEN NULL
		ELSE par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID
	END AS personId,
	(trunc(months_between(TRUNC(cast(:MemberBaseDate as date)), per.birthdate)/12))::VARCHAR AS Age,
    per.FIRSTNAME || ' ' || per.LASTNAME personName,
    --DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS personType,
    --DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'SLETTET','UNKNOWN') AS personStatus,
	CASE  scl_ptype.STATEID  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN 'CONTACT'  ELSE 'UNKNOWN' END AS PERSONTYPE,
	CASE  scl_pstatus.STATEID  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARY INACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN  'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 9 THEN 'CONTACT'  ELSE 'UNKNOWN' END AS PERSONSTATUS,
	par.STATE participationState,
    par.CANCELATION_REASON,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.CENTER || 'p' || ins.ID
    END instructorId,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END instructorName,
    TO_CHAR(longtodate(sub.CREATION_TIME), 'YYYY-MM-DD') newSubscription,
    TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') startdate,
    sub.SUBSCRIPTION_PRICE,
    CASE subtype.ST_TYPE  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'EFT'  ELSE null END AS PaymentType
FROM
    BOOKINGS bk
JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID
LEFT JOIN PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
    AND par.BOOKING_ID = bk.ID
--------------------------------------------------------------
-- persontype at the time choosen
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_ptype
ON
    par.PARTICIPANT_CENTER = scl_ptype.CENTER
    AND par.PARTICIPANT_ID = scl_ptype.ID
    AND scl_ptype.ENTRY_TYPE = 3
    AND longToDate(scl_ptype.ENTRY_START_TIME) <= (cast(:MemberBaseDate as date) +1) -- Date
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > (cast(:MemberBaseDate as date) +1))
-----------------------------------------------------------------	
-- personstatus at the time choosen
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_pstatus
ON
    par.PARTICIPANT_CENTER = scl_pstatus.CENTER
    AND par.PARTICIPANT_ID = scl_pstatus.ID
    AND scl_pstatus.ENTRY_TYPE = 1
    AND longToDate(scl_pstatus.ENTRY_START_TIME) <= (cast(:MemberBaseDate as date) +1) -- Date
    AND
        (scl_pstatus.ENTRY_END_TIME IS NULL
        OR longToDate(scl_pstatus.ENTRY_END_TIME) > (cast(:MemberBaseDate as date) +1))
-----------------------------------------------------------------	
LEFT JOIN STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
    AND bk.id = st.BOOKING_ID
LEFT JOIN PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
    AND st.PERSON_ID = ins.ID
LEFT JOIN PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
    AND par.PARTICIPANT_ID = per.ID
LEFT JOIN SUBSCRIPTIONS sub
ON
    sub.OWNER_CENTER = par.PARTICIPANT_CENTER
    AND sub.OWNER_ID = par.PARTICIPANT_ID
    AND longtodate(sub.CREATION_TIME) < trunc(longtodate(bk.STARTTIME))
    AND longtodate(sub.CREATION_TIME) >= trunc(longtodate(bk.STARTTIME))
LEFT JOIN SUBSCRIPTIONTYPES subtype
ON
    sub.SUBSCRIPTIONTYPE_CENTER = subtype.CENTER
    AND sub.SUBSCRIPTIONTYPE_ID = subtype.ID

LEFT JOIN CENTERS cen
ON
	per.CENTER = cen.ID
LEFT JOIN CENTERS cen_ins
ON
	ins.CENTER = cen_ins.ID
WHERE
    bk.center IN (:ChosenScope)
	AND act.ACTIVITY_TYPE = 4 /* 2=class, 4=staff booking, 6=staff availability */
	AND bk.STARTTIME >= datetolong(TO_CHAR(cast(:MemberBaseDate as date), 'YYYY-MM-DD HH24:MI'))
	AND bk.STARTTIME <= datetolong(TO_CHAR(cast(:MemberBaseDate as date), 'YYYY-MM-DD HH24:MI')) + 86400 * 1000 - 1
    AND bk.STATE = 'ACTIVE'
ORDER BY
    bk.STARTTIME
