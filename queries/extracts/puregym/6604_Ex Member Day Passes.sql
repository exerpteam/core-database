SELECT distinct
     cen.NAME,
    p.CENTER || 'p' || p.ID AS Pref,
    P.FULLNAME,
    DECODE ( P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    trim(P.FIRSTNAME) FIRSTNAME,
    trim(P.LASTNAME) LASTNAME,
    e.IDENTITY as PIN,
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
    pem.txtvalue AS email,    to_char(longtodate(max(scl.ENTRY_START_TIME)),'yyyy-MM-dd') sub_end, DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
p.External_ID
FROM
    STATE_CHANGE_LOG SCL
INNER JOIN
    SUBSCRIPTIONS SU
ON
    (
        SCL.CENTER = SU.CENTER
        AND SCL.ID = SU.ID
        AND SCL.ENTRY_TYPE = 2)
INNER JOIN
    SUBSCRIPTIONTYPES ST
ON
    (
        SU.SUBSCRIPTIONTYPE_CENTER = ST.CENTER
        AND SU.SUBSCRIPTIONTYPE_ID = ST.ID)
INNER JOIN
    PRODUCTS PR
ON
    (
        ST.CENTER = PR.CENTER
        AND ST.ID = PR.ID)
LEFT JOIN
    persons p
ON
    p.center = su.OWNER_CENTER
    AND p.id = su.OWNER_ID
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
WHERE
    (
        p.STATUS = 2
        AND SCL.ENTRY_TYPE = 2
        AND SCL.STATEID IN (2)
        AND ST.ST_TYPE IN (0)
        and P.CENTER IN ($$center$$)
         AND P.PERSONTYPE != 2
        AND EXISTS
        (
            SELECT
                PAPGL.PRODUCT_GROUP_ID AS PAPGL_PRODUCT_GROUP_ID
            FROM
                PRODUCT_AND_PRODUCT_GROUP_LINK PAPGL
            WHERE
                (
                    PR.CENTER = PAPGL.PRODUCT_CENTER
                    AND PR.ID = PAPGL.PRODUCT_ID
                    AND PAPGL.PRODUCT_GROUP_ID IN (603))) )
                    group by cen.NAME,
    p.CENTER, p.ID,
    P.FULLNAME,
    P.PERSONTYPE,
    P.FIRSTNAME,
    P.LASTNAME,
    e.IDENTITY,
    P.SEX,
    P.BLACKLISTED,
    P.ADDRESS1,
    P.ADDRESS2,
    P.COUNTRY,
    P.ZIPCODE,
    P.BIRTHDATE,
    P.CITY,
    ph.txtvalue,
    pm.txtvalue,
    pem.txtvalue,p.STATUS,p.External_ID