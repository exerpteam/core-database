-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    cen.NAME,
    p.CENTER || 'p' || p.ID AS Pref,
    P.FULLNAME,
    DECODE ( P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    trim(P.FIRSTNAME) FIRSTNAME,
    trim(P.LASTNAME) LASTNAME,
    e.IDENTITY,
    P.SEX,
    P.BLACKLISTED,
    P.ADDRESS1,
    P.ADDRESS2,
    P.COUNTRY,
    P.ZIPCODE,
    P.BIRTHDATE,
    P.CITY,
    ph.txtvalue  AS phonehome,
    pm.txtvalue  AS phonemobile,
    pem.txtvalue AS email,
    s.START_DATE,
    s.END_DATE,
DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
p.External_ID
FROM
    PERSONS P
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
    ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER=p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = p.CENTER
JOIN
    PUREGYM.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.id
    AND s.STATE IN (2,4)
JOIN
    PUREGYM.PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
    AND pr.GLOBALID IN ('DAY_PASS_30_DAY',
                        'DAY_PASS_3_DAY',
                        'DAY_PASS_1_DAY',
                        'DAY_PASS_7_DAY')
WHERE
    p.center IN ($$scope$$)
    AND P.STATUS IN (1,3)
    AND P.PERSONTYPE != 2