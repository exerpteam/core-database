SELECT DISTINCT
    C.NAME                                                                                                                                                    AS CENTERNAME,
    P.CENTER || 'p' || P.ID                                                                                                                                   AS MEMBER_ID,
    MAX(TO_CHAR(longToDateTZ(S.CREATION_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI'))                                                                         AS "CREATION TIME",
    P.FULLNAME                                                                                                                                                AS FULLNAME,
    cops.lastname                                                                                                                                             AS COMPANYNAME,
    DECODE ( P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN' )        AS STATUS,
    DECODE ( P.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN' ) AS PERSONTYPE,
    P.SEX                                                                                                                                                     AS SEX ,
    P.BIRTHDATE                                                                                                                                               AS BIRTHDATE,
    P.ADDRESS1                                                                                                                                                AS ADDRESS1,
    P.ADDRESS2                                                                                                                                                AS ADDRESS2,
    P.ADDRESS3                                                                                                                                                AS ADDRESS3,
    P.ZIPCODE                                                                                                                                                 AS ZIPCODE,
    P.CITY                                                                                                                                                    AS CITY,
    P.COUNTRY                                                                                                                                                 AS COUNTRY,
    ph.TXTVALUE                                                                                                                                               AS PHONEHOME,
    pm.TXTVALUE                                                                                                                                               AS PHONEMOBILE,
    pem.txtvalue                                                                                                                                              AS EMAIL
FROM
    PERSONS P
JOIN
    CENTERS C
ON
    P.CENTER = C.ID
LEFT JOIN
    SUBSCRIPTIONS S
ON
    P.CENTER = S.OWNER_CENTER
    AND P.ID = S.OWNER_ID
LEFT JOIN
    SUBSCRIPTIONTYPES T
ON
    T.CENTER = S.SUBSCRIPTIONTYPE_CENTER
    AND T.ID = S.SUBSCRIPTIONTYPE_ID
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
    persons cops
ON
    cops.center = r.center
    AND cops.id = r.id
WHERE
    P.CENTER IN (:Scope)
    AND S.CREATION_TIME >= :FromDate
    AND S.CREATION_TIME < (:ToDate + 24*3600*1000)
    AND (
        T.CENTER, T.ID) NOT IN
    (
        SELECT
            center,
            id
        FROM
            V_EXCLUDED_SUBSCRIPTIONS)
GROUP BY
    C.NAME,
    P.CENTER || 'p' || P.ID,
    P.FULLNAME,
    cops.lastname,
    P.STATUS,
    P.PERSONTYPE,
    P.SEX,
    P.BIRTHDATE,
    P.ADDRESS1,
    P.ADDRESS2,
    P.ADDRESS3,
    P.ZIPCODE,
    P.CITY,
    P.COUNTRY,
    ph.TXTVALUE,
    pm.TXTVALUE,
    pem.txtvalue
ORDER BY
 MAX(TO_CHAR(longToDateTZ(S.CREATION_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI')) 