-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    cen.NAME,
    p.CENTER || 'p' || p.ID AS Pref,
    P.FULLNAME,
    DECODE ( P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    P.FIRSTNAME,
    P.LASTNAME,
    e.IDENTITY,
    pea_relational.TXTVALUE as "TRP_RELATIONAL",
    pea_attendance.TXTVALUE as "TRP_ATTENDANCE",
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
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS pea_attendance
        ON
            pea_attendance.personcenter = p.center
            AND pea_attendance.personid = p.id
            AND pea_attendance.NAME = 'ATTENDANCE_NPS'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS pea_relational
        ON
            pea_relational.personcenter = p.center
            AND pea_relational.personid = p.id
            AND pea_relational.NAME = 'RELATIONAL_NPS'     
    
    
LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = p.CENTER
WHERE
    p.center IN (:scope)
    AND P.STATUS = 0
    AND P.PERSONTYPE != 2