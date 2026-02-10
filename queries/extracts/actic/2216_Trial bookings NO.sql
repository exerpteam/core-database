-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    c.SHORTNAME                                                                                                                                                AS "Center",
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD')                                                                                                               dato,
    act.NAME                                                                                                                                                      activityname,
    bk.STATE                                                                                                                                                      bookingState,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID                                                                                                           personId,
    per.FIRSTNAME || ' ' || per.LASTNAME                                                                                                                          personName,
    CASE  per.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS personType,
    CASE  per.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN  'PROSPECT'  WHEN 7 THEN 'SLETTET' ELSE 'UNKNOWN' END        AS personStatus,
    ext_email.txtvalue                                                                                                                                            Email,
    ext_sms.txtvalue                                                                                                                                              SMS,
    par.STATE                                                                                                                                                     participationState,
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
    END                                                  instructorName,
    TO_CHAR(longtodate(sub.CREATION_TIME), 'YYYY-MM-DD') newSubscription,
    TO_CHAR(sub.START_DATE, 'YYYY-MM-DD')                startdate,
    sub.SUBSCRIPTION_PRICE,
    CASE subtype.ST_TYPE  WHEN 0 THEN  'CASH'  WHEN 1 THEN  'AG'  ELSE NULL END as type
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
    AND longtodate(sub.CREATION_TIME) < TRUNC(longtodate(bk.STARTTIME)) + (:Weeks * 7)
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
WHERE
    bk.center IN (:ChosenScope)
    AND act.NAME IN (:activityName)
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + 3600*1000*24
    AND bk.STATE = 'ACTIVE'
ORDER BY
    bk.STARTTIME
