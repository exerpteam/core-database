SELECT
    p.center||'p'||p.id                              AS "MEMBER_ID",
    c1.SHORTNAME                                     AS "PAYER_CENTER_NAME",
    c2.SHORTNAME                                     AS "SUBSCRIPTION_CENTER_NAME",
    salutation.TXTVALUE                              AS "SALUTATION",
    p.FULLNAME                                       AS "FULL_NAME",
    p.ADDRESS1                                       AS "ADDRESS1",
    p.ADDRESS2                                       AS "ADDRESS2",
    p.ADDRESS3                                       AS "ADDRESS3",
    p.ZIPCODE                                        AS "POST_CODE",
    p.CITY                                           AS "CITY",
    z.COUNTY                                         AS "COUNTY",
    p.COUNTRY                                        AS "COUNTRY",
    pea1.TXTVALUE                                    AS "WORK_PHONE",
    pea2.TXTVALUE                                    AS "MOBILE_PHONE",
    pea3.TXTVALUE                                    AS "HOME_PHONE",
    sp.SUBSCRIPTION_CENTER||'ss'||sp.SUBSCRIPTION_ID AS "SUBSCRIPTION_ID",
    sp.FROM_DATE                                     AS "PRICE_FROM_DATE",
    sp.price                                         AS "SCHEDULED_PRICE",
    s.SUBSCRIPTION_PRICE                             AS "CURRENT_PRICE"
FROM
    VA.MESSAGES m
JOIN
    VA.PERSONS p
ON
    p.center = m.center
    AND p.id = m.id
LEFT JOIN
    VA.PERSON_EXT_ATTRS pea
ON
    pea.PERSONCENTER = m.center
    AND pea.PERSONID = m.id
    AND pea.NAME = '_eClub_Email'
    AND pea.TXTVALUE IS NOT NULL
    --and pea.TXTVALUE = ''
LEFT JOIN
    VA.SUBSCRIPTION_PRICE sp
ON
    'sp'||sp.id = m.REFERENCE
JOIN
    VA.SUBSCRIPTIONS s
ON
    s.center = sp.SUBSCRIPTION_CENTER
    AND s.id = sp.SUBSCRIPTION_ID
JOIN
    centers c1
ON
    c1.id = m.center
JOIN
    centers c2
ON
    c2.id = s.center
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center=salutation.PERSONCENTER
    AND p.id=salutation.PERSONID
    AND salutation.name='_eClub_Salutation'
LEFT JOIN
    ZIPCODES z
ON
    z.COUNTRY = p.COUNTRY
    AND z.ZIPCODE = p.ZIPCODE
    AND z.CITY = p.CITY
LEFT JOIN
    PERSON_EXT_ATTRS pea1
ON
    pea1.name ='_eClub_PhoneWork'
    AND pea1.PERSONCENTER = p.center
    AND pea1.PERSONID =p.id
LEFT JOIN
    PERSON_EXT_ATTRS pea2
ON
    pea2.name ='_eClub_PhoneSMS'
    AND pea2.PERSONCENTER = p.center
    AND pea2.PERSONID =p.id
LEFT JOIN
    PERSON_EXT_ATTRS pea3
ON
    pea3.name ='_eClub_PhoneHome'
    AND pea3.PERSONCENTER = p.center
    AND pea3.PERSONID =p.id
WHERE
    m.MESSAGE_TYPE_ID = 116
    AND m.DELIVERYCODE = 14
    AND pea.PERSONCENTER IS NULL
    AND m.DELIVERYMETHOD = 1