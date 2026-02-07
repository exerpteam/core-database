SELECT DISTINCT
    P.CENTER,
    P.CENTER||'p'||P.ID as CUSTOMER_ID,
    (
        SELECT
            c.lastname
        FROM
            persons c
        WHERE
            c.center = r.center
            AND c.id = r.id ) AS companyname,
    P.BLACKLISTED,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
   DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
    P.FIRSTNAME,
    P.MIDDLENAME,
    P.LASTNAME,
    P.ADDRESS1,
    P.ADDRESS2,
    P.COUNTRY,
    P.ZIPCODE,
    P.BIRTHDATE,
    P.SEX,
    P.PINCODE,
    P.FRIENDS_ALLOWANCE,
    P.CITY,
    ph.txtvalue  AS phonehome,
    pm.txtvalue  AS phonemobile,
    pem.txtvalue AS email
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
    P.CENTER IN (304,310)
    AND P.STATUS IN ( 1,2,0,6,3,9)
and 
    p.CENTER = p.CURRENT_PERSON_CENTER
    AND p.id = p.CURRENT_PERSON_ID