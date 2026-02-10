-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    cen.NAME,
    p.center,
    p.center||'p'||p.id as pref,
    p.FULLNAME,
    p.FIRSTNAME,
    p.LASTNAME,
    p.center||'p'||p.id AS MemberID,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    e2.IDENTITY                                                        AS PIN,
    email.TXTVALUE                                                     AS Email,
    home.TXTVALUE                                                      AS PHONEHOME,
    mobile.TXTVALUE                                                    AS MOBILE,
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE, 'YYYY-MM-DD'), pea.txtvalue) AS MemberSinceDate,
    TO_CHAR(longtodatetz(su.CREATION_TIME,'Europe/London'),'HH24:MI') AS MemberSinceTime                                                   
FROM
    (
        SELECT
           $$for_date$$ AS DATETIME
        FROM
            DUAL ) PARAMS,
    PUREGYM.ENTITYIDENTIFIERS e
JOIN
    PUREGYM.PERSONS p
ON
    p.center = e.REF_CENTER
    AND p.id = e.REF_ID
JOIN
    PUREGYM.PERSONS p2
ON
    p2.CURRENT_PERSON_CENTER = p.CURRENT_PERSON_CENTER
    AND p2.CURRENT_PERSON_ID = p.CURRENT_PERSON_ID
LEFT JOIN
    PUREGYM.SUBSCRIPTIONS su
ON
    su.OWNER_CENTER = p2.center
    AND su.OWNER_ID = p2.id
    AND TRUNC(longtodatetz(su.CREATION_TIME,'Europe/London')) = p.LAST_ACTIVE_START_DATE
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS pea
ON
    p.center=pea.PERSONCENTER
    AND p.id=pea.PERSONID
    AND pea.name='CREATION_DATE'
LEFT JOIN
    ENTITYIDENTIFIERS e2
ON
    e2.IDMETHOD = 5
    AND e2.ENTITYSTATUS = 1
    AND e2.REF_CENTER=p.CENTER
    AND e2.REF_ID = p.ID
    AND e2.REF_TYPE = 1
LEFT JOIN
    PUREGYM.CENTERS cen
ON
    cen.ID = p.CENTER
WHERE
    e.REF_TYPE = 1
    AND e.IDMETHOD = 4
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER IN ($$scope$$)
    AND e.START_TIME < params.datetime
    AND (
        e.STOP_TIME > params.datetime
        OR e.STOP_TIME IS NULL)