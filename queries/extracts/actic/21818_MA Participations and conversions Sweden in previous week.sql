-- The extract is extracted from Exerp on 2026-02-08
-- Exported to CM weekly
Activitys included:  (14244, 14240, 14235, 18417, 18817, 18821, 18822, 18823)
SELECT
    c.SHORTNAME                                                                                                                                                AS "Center",
   TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD')                                                                                   dato,
TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD') todays_date,  
    act.NAME                                                                                                                                                      activityname,
    bk.STATE                                                                                                                                                      bookingState,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID                                                                                                           personId,
    --per.FIRSTNAME || ' ' || per.LASTNAME  
	                                                                                                                       --personName,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6, 'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS personType,
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6, 'PROSPECT', 7,'SLETTET','UNKNOWN')        AS personStatus,
    --ext_email.txtvalue                                                                                                                                            --Email,
    --ext_sms.txtvalue                                                                                                                                              --SMS,
    par.STATE                                                                                                                                                     participationState,
    par.CANCELATION_REASON,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.CENTER || 'p' || ins.ID
    END instructorId,
    --CASE
        --WHEN ins.CENTER IS NULL
        --THEN NULL
        --ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    --END                                                  instructorName,
prod.name,
    TO_CHAR(longtodate(sub.CREATION_TIME), 'YYYY-MM-DD') newSubscription,
    TO_CHAR(sub.START_DATE, 'YYYY-MM-DD')                startdate,
    sub.SUBSCRIPTION_PRICE,
    DECODE(subtype.ST_TYPE, 0, 'CASH', 1, 'AG', NULL) type
	
FROM
    BOOKINGS bk
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
	 AND st.STATE != 'CANCELLED'
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
    SUBSCRIPTIONS sub
ON
    sub.OWNER_CENTER = par.PARTICIPANT_CENTER
    AND sub.OWNER_ID = par.PARTICIPANT_ID
  
  AND longtodate(sub.CREATION_TIME) >= TRUNC(longtodate(bk.STARTTIME))
LEFT JOIN
    SUBSCRIPTIONTYPES subtype
ON
    sub.SUBSCRIPTIONTYPE_CENTER = subtype.CENTER
    AND sub.SUBSCRIPTIONTYPE_ID = subtype.ID


LEFT JOIN
    PERSON_EXT_ATTRS ext_email
ON
    ext_email.PERSONCENTER = per.CENTER
    AND ext_email.PERSONID = per.ID
    AND ext_email.name = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS ext_sms
ON
    ext_sms.PERSONCENTER = per.CENTER
    AND ext_sms.PERSONID = per.ID
    AND ext_sms.name = '_eClub_PhoneSMS'
JOIN
    CENTERS c
ON
    c.id = bk.CENTER

LEFT JOIN PRODUCTS prod
ON
	sub.SUBSCRIPTIONTYPE_CENTER = prod.CENTER
	AND sub.SUBSCRIPTIONTYPE_ID	= prod.ID

WHERE
    bk.center IN (:ChosenScope)
    AND act.id IN (14244, 14240, 14235, 18417, 18817, 18821, 18822, 18823)
AND bk.STARTTIME >= datetolong(TO_CHAR(TRUNC(exerpsysdate(), 'IW')- 7, 'YYYY-MM-DD HH24:MI'))
	AND bk.STARTTIME < datetolong(TO_CHAR(TRUNC(exerpsysdate(), 'IW'), 'YYYY-MM-DD HH24:MI'))


    AND bk.STATE = 'ACTIVE'
ORDER BY
    bk.STARTTIME