SELECT
    p.center||'p'||p.id MemberID,
    p.FIRSTNAME,
    p.LASTNAME,
    p.ADDRESS1,
    p.ZIPCODE,
    p.CITY,
    p.COUNTRY,
    mobile.TXTVALUE AS mobile,
    email.TXTVALUE  AS email,
    pa.BANK_ACCNO   AS "Bank ACcount Number",
    c.name          AS "Homecenter Name",
    c.ID            AS "Homecenter ID",
	ss.SALES_DATE
FROM
    SATS.PERSONS p
JOIN
    SATS.centers c
ON
    c.id = p.center
JOIN
    SATS.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.id
    AND (
        s.SUB_STATE != 8)
JOIN
    SATS.SUBSCRIPTIONTYPES st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    SATS.SUBSCRIPTION_SALES ss
ON
    ss.SUBSCRIPTION_CENTER = s.center
    AND ss.SUBSCRIPTION_ID = s.id
JOIN
    SATS.ACCOUNT_RECEIVABLES ar
ON
    ar.CUSTOMERCENTER = p.CENTER
    AND ar.CUSTOMERID = p.id
    AND ar.AR_TYPE =4
JOIN
    SATS.PAYMENT_ACCOUNTS pac
ON
    pac.center = ar.center
    AND pac.id = ar.id
JOIN
    SATS.PAYMENT_AGREEMENTS pa
ON
    pa.CENTER = pac.ACTIVE_AGR_CENTER
    AND pa.id = pac.ACTIVE_AGR_ID
    AND pa.SUBID = pac.ACTIVE_AGR_SUBID
LEFT JOIN
    SATS.PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER = p.CENTER
    AND email.PERSONID = p.ID
    AND email.NAME = '_eClub_Email'
LEFT JOIN
    SATS.PERSON_EXT_ATTRS mobile
ON
    mobile.PERSONCENTER = p.CENTER
    AND mobile.PERSONID = p.ID
    AND mobile.NAME = '_eClub_PhoneSMS'
WHERE
    ss.SALES_DATE = TRUNC(exerpsysdate()-$$offset$$)
    AND p.center IN ($$scope$$)
    AND p.center NOT IN (:CenterExcluded)
    AND st.ST_TYPE =1
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.SUBSCRIPTION_CHANGE sc
        WHERE
            sc.NEW_SUBSCRIPTION_CENTER = s.center
            AND sc.NEW_SUBSCRIPTION_ID = s.id)