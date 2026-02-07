/*
 * TrialbookingConversions in specified period MANUAL
 */
-- TODO
-- Make sure that it show historical persontype in case of period is way back

SELECT
	cen.COUNTRY,
	cen.EXTERNAL_ID AS Cost,
	TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') AS dato,
	act.ID AS ActivityID,
   	act.NAME activityname,
    bk.STATE bookingState,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
	TO_CHAR(trunc(months_between(TRUNC(:MemberBaseDate), per.birthdate)/12)) AS Age,
    per.FIRSTNAME || ' ' || per.LASTNAME personName,
    DECODE (scl_ptype.STATEID, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST', 9,'CONTACT', 'UNKNOWN') AS PERSONTYPE,
    DECODE (scl_pstatus.STATEID, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARY INACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT',7,'DELETED',9,'CONTACT', 'UNKNOWN')  AS PERSONSTATUS,
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
    TO_CHAR(longtodate(sub.CREATION_TIME), 'YYYY-MM-DD') Salesdate,
    TO_CHAR(sub.START_DATE, 'YYYY-MM-DD') startdate,
    sub.SUBSCRIPTION_PRICE,
    DECODE(subtype.ST_TYPE, 0, 'CASH', 1, 'EFT', null) AS PaymentType,
	prod.NAME AS Product_Name,
	prod.GLOBALID AS Global_Id,
	pg.NAME AS Product_Group
FROM BOOKINGS bk
	
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
    AND longToDate(scl_ptype.ENTRY_START_TIME) <= (:MemberBaseDate +1) -- Date
    AND
        (scl_ptype.ENTRY_END_TIME IS NULL
        OR longToDate(scl_ptype.ENTRY_END_TIME) > (:MemberBaseDate +1))
-----------------------------------------------------------------	
-- personstatus at the time choosen
-- added by MB
LEFT JOIN STATE_CHANGE_LOG scl_pstatus
ON
    par.PARTICIPANT_CENTER = scl_pstatus.CENTER
    AND par.PARTICIPANT_ID = scl_pstatus.ID
    AND scl_pstatus.ENTRY_TYPE = 1
    AND longToDate(scl_pstatus.ENTRY_START_TIME) <= (:MemberBaseDate +1) -- Date
    AND
        (scl_pstatus.ENTRY_END_TIME IS NULL
        OR longToDate(scl_pstatus.ENTRY_END_TIME) > (:MemberBaseDate +1))
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
    AND TO_CHAR(longtodate(sub.CREATION_TIME), 'YYYY-MM-DD') LIKE TO_CHAR(:MemberBaseDate, 'YYYY-MM-DD')

	
LEFT JOIN SUBSCRIPTIONTYPES subtype
ON
    sub.SUBSCRIPTIONTYPE_CENTER = subtype.CENTER
    AND sub.SUBSCRIPTIONTYPE_ID = subtype.ID
LEFT JOIN PRODUCTS prod
ON
    subtype.CENTER = prod.CENTER
    AND subtype.ID = prod.ID
LEFT JOIN PRODUCT_GROUP pg
ON
	prod.PRIMARY_PRODUCT_GROUP_ID = pg.ID
LEFT JOIN CENTERS cen
ON
	per.CENTER = cen.ID
WHERE
    bk.center IN (:ChosenScope)
	-- AND longtodate(bk.STARTTIME) BETWEEN conversionDate - 12 * 7 AND conversionDate --date
	AND bk.STARTTIME BETWEEN datetolong(TO_CHAR(TRUNC(:MemberBaseDate - 12 * 7), 'YYYY-MM-DD HH24:MI')) AND (datetolong(TO_CHAR(TRUNC(:MemberBaseDate), 'YYYY-MM-DD HH24:MI')) + 86399 * 1000)
	/* AND act.ID IN (20, 201, 205, 605, 606, 607, 2815, 2859, 10407, 10408, 13407, 13629, 13630, 13631, 13632, 13633, 13634, 13635, 13637, 13638, 13639, 13641, 13642, 13643, 13645, 13646, 13647, 13649, 13650, 13651) */

	AND act.ACTIVITY_TYPE = 4 /* 2=class, 4=staff booking, 6=staff availability */
    -- AND bk.STARTTIME BETWEEN fromDate AND toDate --long date
    AND bk.STATE = 'ACTIVE'
	AND sub.CREATION_TIME IS NOT NULL
ORDER BY
    bk.STARTTIME