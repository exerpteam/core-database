SELECT DISTINCT
    P.CENTER,
    P.ID,
    cen.NAME,
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
LEFT JOIN
     centers cen
     on
     cen.ID = p.CENTER

WHERE
    P.CENTER IN (:center)
    AND (
        S.SUBSCRIPTIONTYPE_CENTER, S.SUBSCRIPTIONTYPE_ID) IN
    (
        SELECT
            center,
            id
        FROM
            PRODUCTS
        WHERE
            PTYPE = 10
            AND GLOBALID IN ( :globalsubtype )
            AND center IN (S.CENTER))
    AND S.START_DATE >= :Start_Date_From
    AND S.START_DATE <= :Start_Date_To