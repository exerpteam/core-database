SELECT DISTINCT
    P.CENTER,
    P.ID,
    P.FULLNAME,
    (
        SELECT
            c.lastname
        FROM
            persons c
        WHERE
            c.center = r.center
        AND c.id = r.id ) AS companyname,
    P.STATUS,
    P.PERSONTYPE,
    P.FIRSTNAME,
    P.LASTNAME,
    P.SEX,
    P.BLACKLISTED,
    P.ADDRESS1,
    P.ADDRESS2,
    P.COUNTRY,
    P.ZIPCODE,
    P.BIRTHDATE,
    P.PINCODE,
    P.FRIENDS_ALLOWANCE,
    P.CITY,
    ph.txtvalue  AS phonehome,
    pm.txtvalue  AS phonemobile,
    pem.txtvalue AS email,
    P.MIDDLENAME
FROM
    PERSONS P
LEFT JOIN
    SUBSCRIPTIONS S
ON
    P.CENTER = S.OWNER_CENTER
AND P.ID = S.OWNER_ID
LEFT JOIN
    relatives r
ON
    p.center = r.relativecenter
AND p.id = r.relativeid
AND r.rtype = 2
AND r.status <> 3
LEFT JOIN
    person_ext_attrs ph
ON
    ph.personcenter = p.center
AND ph.personid = p.id
AND ph.name = '_eClub_PhoneHome'
LEFT JOIN
    person_ext_attrs pem
ON
    pem.personcenter = p.center
AND pem.personid = p.id
AND pem.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs pm
ON
    pm.personcenter = p.center
AND pm.personid = p.id
AND pm.name = '_eClub_PhoneSMS'
WHERE
    P.CENTER IN (:scope)
	AND P.STATUS in (1,3)
AND EXISTS
    (
        SELECT
            CHECKINS.PERSON_CENTER,
            CHECKINS.PERSON_ID,
            COUNT(*) AS NB
        FROM
            CHECKINS
        WHERE
            CHECKINS.PERSON_CENTER = P.CENTER
        AND CHECKINS.PERSON_ID = P.ID
        AND CHECKIN_TIME BETWEEN :Check_in_from_date AND (
                :Check_in_To_date + 86400 * 1000 - 1)
        GROUP BY
            CHECKINS.PERSON_CENTER,
            CHECKINS.PERSON_ID
        HAVING
            COUNT(*) BETWEEN :min AND :max )
AND EXISTS
    (
        SELECT
            *
        FROM
            PERSON_EXT_ATTRS
        WHERE
            PERSONCENTER= P.CENTER
        AND PERSONID = P.ID
        AND NAME = 'eClubIsAcceptingEmailNewsLetters'
        AND PERSON_EXT_ATTRS.TXTVALUE = 'true')