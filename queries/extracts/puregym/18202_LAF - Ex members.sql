-- The extract is extracted from Exerp on 2026-02-08
-- YesMail
SELECT distinct
    cen.NAME,
    p.CENTER || 'p' || p.ID AS Pref,
    P.FULLNAME,
    DECODE ( P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    P.FIRSTNAME,
    P.LASTNAME,
    e.IDENTITY AS PIN,
    pea_relational.TXTVALUE as TRP_RELATIONAL,
    pea_attendance.TXTVALUE as TRP_ATTENDANCE,
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
    p.EXTERNAL_ID,
    DECODE(AEM.TXTVALUE, 'true',1,'false',0,NULL)  AS "Opt in to emails",
    DECODE(ANL.TXTVALUE, 'true',1,'false',0,NULL)  AS "Opt in to News Letter"
FROM
    PERSONS P -- current member
JOIN
    PUREGYM.PERSONS p2 --all the transferred members and the current member
ON
    p2.CURRENT_PERSON_CENTER = p.CENTER
    AND p2.CURRENT_PERSON_ID = p.ID
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
    PUREGYM.PERSON_EXT_ATTRS AEM
ON
    AEM.PERSONCENTER = p.CENTER
    AND AEM.PERSONID = p.ID
    AND AEM.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN
    PUREGYM.PERSON_EXT_ATTRS ANL
ON
    ANL.PERSONCENTER = p.CENTER
    AND ANL.PERSONID = p.ID
    AND ANL.NAME = 'eClubIsAcceptingEmailNewsLetters'

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

LEFT JOIN
    (
        SELECT
            op.CURRENT_PERSON_CENTER,
            op.CURRENT_PERSON_ID,
            MAX(s.START_DATE) START_DATE
        FROM
            PUREGYM.SUBSCRIPTIONS s
        JOIN
            PUREGYM.PERSONS op
        ON
            op.CENTER = s.OWNER_CENTER
            AND op.id = s.OWNER_ID
        WHERE
            s.STATE != 5
        GROUP BY
            op.CURRENT_PERSON_CENTER,
            op.CURRENT_PERSON_ID) last_sub
ON
    last_sub.CURRENT_PERSON_CENTER = p.CENTER
    AND last_sub.CURRENT_PERSON_ID = p.id
LEFT JOIN
    PUREGYM.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p2.CENTER
    AND s.OWNER_ID = p2.id
    AND s.START_DATE = last_sub.START_DATE
LEFT JOIN
    PUREGYM.SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PUREGYM.PRODUCTS pr
ON
    pr.CENTER = st.CENTER
    AND pr.id = st.ID
    AND pr.GLOBALID = 'LA_FITNESS_EXMEMBER'
WHERE
    P.CENTER IN ($$center$$)
    AND P.STATUS = 2
    AND P.PERSONTYPE != 2
    