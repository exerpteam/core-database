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
    c.name              AS "Homecenter Name",
    c.ID                AS "Homecenter ID"
FROM
    SATS.PERSONS p
join SATS.centers c on c.id = p.center
JOIN
    SATS.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.id
    AND s.END_DATE IS NOT NULL
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
JOIN
    SATS.SUBSCRIPTION_CHANGE sc
ON
    sc.OLD_SUBSCRIPTION_CENTER = s.CENTER
    AND sc.OLD_SUBSCRIPTION_ID = s.id
    AND sc.CHANGE_TIME BETWEEN dateToLong(TO_CHAR(TRUNC(exerpsysdate()-1 - $$offset$$), 'YYYY-MM-dd HH24:MI')) AND dateToLong(TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-dd HH24:MI'))
    AND sc.TYPE = 'END_DATE'
WHERE

    NOT EXISTS
    (
        SELECT
            1
        FROM
            SATS.SUBSCRIPTIONS s2
        JOIN
            SATS.PERSONS p2
        ON
            p2.CENTER = s2.OWNER_CENTER
            AND p2.id = s2.OWNER_ID
        WHERE
            p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
            AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
            AND (
                s2.END_DATE > s.END_DATE
                OR s2.END_DATE IS NULL)
            AND (
                s2.START_DATE <=s2.END_DATE
                OR s2.END_DATE IS NULL))
and p.center in ($$scope$$)
and p.center not in (:CenterExcluded)