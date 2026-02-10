-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    c.NAME              AS CENTERNAME,
    p.CENTER||'p'||p.id AS MEMBER_ID,
    pea.TXTVALUE        AS CREATION_TIME,
    p.FULLNAME,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
    p.SEX,
    TO_CHAR(p.BIRTHDATE,'yyyy-MM-dd') BIRTHDATE,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    p.CITY,
    p.COUNTRY,
    home.TXTVALUE                      AS PHONEHOME,
    mobile.TXTVALUE                    AS PHONEMOBILE,
    email.TXTVALUE                     AS EMAIL,
    pr.NAME                            AS "Subscription name",
    TO_CHAR(s.START_DATE,'yyyy-MM-dd') AS "Subscription start date",
    TO_CHAR(s.END_DATE,'yyyy-MM-dd')   AS "Subscription end date"
FROM
    PUREGYM.SUBSCRIPTIONS s
JOIN
    PUREGYM.PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    PUREGYM.PRODUCTS pr
ON
    s.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
    AND s.SUBSCRIPTIONTYPE_ID = pr.id
    AND pr.GLOBALID IN ('GYMFLEX_12M_EFT',
                        'GYMFLEX_9M_EFT')
JOIN
    PUREGYM.CENTERS c
ON
    c.id = p.CENTER
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = p.CENTER
    AND pea.PERSONID = p.id
    AND pea.NAME = 'CREATION_DATE'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
WHERE
    s.STATE IN (2,4)