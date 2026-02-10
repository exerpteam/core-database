-- The extract is extracted from Exerp on 2026-02-08
--  
/*
 * Trialbookings in specified period
 */
-- TODO
-- Make sure that it show historical persontype in case of period is way back
-- Add subscription and paymenttype. This way we can follow when follow-ups is in relation to subcription startdate
WITH
    PARAMS AS
    (
        SELECT
                /*+ materialize */
				datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) AS fromDate,
                datetolongTZ(TO_CHAR(TRUNC(to_date(getcentertime(c.id), 'YYYY-MM-DD HH24:MI')-1), 'YYYY-MM-DD HH24:MI'),co.DEFAULTTIMEZONE) + 86399000 AS toDate,
                c.ID AS CenterID
        FROM CENTERS c
        JOIN COUNTRIES co ON c.COUNTRY = co.ID
    )
SELECT
	CASE
		WHEN per.CENTER IS NULL THEN cen_ins.COUNTRY
		ELSE cen.COUNTRY
	END AS Country,
--	cen.COUNTRY,
	CASE
		WHEN per.CENTER IS NULL THEN cen_ins.EXTERNAL_ID
		ELSE cen.EXTERNAL_ID
	END AS Cost,
--	cen.EXTERNAL_ID AS Cost,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
	act.ID AS ActivityID,
   	act.NAME activityname,
    bk.STATE bookingState,
	CASE
		WHEN per.CENTER IS NULL THEN NULL
		ELSE par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID
	END AS personId,
--  par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
    EXTRACT('year' FROM age(per.birthdate))::VARCHAR AS Age,
    per.FIRSTNAME || ' ' || per.LASTNAME personName,
    CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST'  WHEN 9 THEN 'CONTACT'  ELSE 'UNKNOWN' END AS personType,
    CASE  per.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARY INACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN  'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 9 THEN 'CONTACT'  ELSE 'UNKNOWN' END AS personStatus,
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
JOIN 
	PARAMS params ON params.CenterID = bk.CENTER
JOIN ACTIVITY act
ON
    bk.ACTIVITY = act.ID
LEFT JOIN PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
    AND par.BOOKING_ID = bk.ID
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
	/* AND act.ID IN (20, 201, 205, 605, 606, 607, 2815, 2859, 10407, 10408, 13407, 13629, 13630, 13631, 13632, 13633, 13634, 13635, 13637, 13638, 13639, 13641, 13642, 13643, 13645, 13646, 13647, 13649, 13650, 13651, 16008) */
	AND act.ACTIVITY_TYPE = 4 /* 2=class, 4=staff booking, 6=staff availability */
    AND bk.STARTTIME >= params.fromDate -- yesterday at midnight
	AND bk.STARTTIME < params.toDate -- yesterday at midnight +24 hours in ms
    AND bk.STATE = 'ACTIVE'
ORDER BY
    bk.STARTTIME
