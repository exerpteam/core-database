 nSELECT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') dato,
   	act.NAME activityname,
    bk.STATE bookingState,
    par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID personId,
    per.FIRSTNAME || ' ' || per.LASTNAME personName,
    DECODE (per.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,
    'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS personType,
    DECODE (per.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,
    'PROSPECT', 7,'SLETTET','UNKNOWN') AS personStatus,
	c.name as Centername,
	company.LASTNAME 		AS Company_Name,
	CA.NAME 				AS AGREEMENT_NAME,												
    ext_email.txtvalue Email,
	ext_sms.txtvalue SMS, 
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
    DECODE(subtype.ST_TYPE, 0, 'CASH', 1, 'AG', null) type
FROM
    BOOKINGS bk
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
    AND longtodate(sub.CREATION_TIME) < trunc(longtodate(bk.STARTTIME)) + (:Weeks * 7)
    AND longtodate(sub.CREATION_TIME) >= trunc(longtodate(bk.STARTTIME))
LEFT JOIN SUBSCRIPTIONTYPES subtype
ON
    sub.SUBSCRIPTIONTYPE_CENTER = subtype.CENTER
    AND sub.SUBSCRIPTIONTYPE_ID = subtype.ID
LEFT JOIN PERSON_EXT_ATTRS ext_email
ON
	ext_email.PERSONCENTER = per.CENTER
	and ext_email.PERSONID = per.ID
	and ext_email.name = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS ext_sms
ON
	ext_sms.PERSONCENTER = per.CENTER
	and ext_sms.PERSONID = per.ID
	and ext_sms.name = '_eClub_PhoneSMS'
LEFT JOIN CENTERS c
On
	c.id = per.center

LEFT JOIN RELATIVES companyAgrRel
ON
    per.center = companyAgrRel.CENTER
    AND per.ID = companyAgrRel.ID
    AND companyAgrRel.RTYPE = 3
    AND companyAgrRel.STATUS = 1
LEFT JOIN COMPANYAGREEMENTS ca
ON
    ca.CENTER = companyAgrRel.RELATIVECENTER
    AND ca.ID = companyAgrRel.RELATIVEID
    AND ca.SUBID = companyAgrRel.RELATIVESUBID
LEFT JOIN PERSONS company
ON
    company.CENTER = ca.CENTER
    AND company.ID = ca.id
    AND company.sex = 'C'	
	
WHERE
    bk.center IN (:ChosenScope)
    AND act.NAME IN (:activityName)
    AND bk.STARTTIME >= :FromDate
    AND bk.STARTTIME < :ToDate + 3600*1000*24
    AND bk.STATE = 'ACTIVE'
	AND per.PERSONTYPE = '4'
ORDER BY
    bk.STARTTIME