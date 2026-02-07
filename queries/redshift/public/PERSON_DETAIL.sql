SELECT
    p.EXTERNAL_ID   AS "PERSON_ID",
    p.ADDRESS1      AS "ADDRESS1",
    p.ADDRESS2      AS "ADDRESS2",
    p.ADDRESS3      AS "ADDRESS3",
    pea1.TXTVALUE   AS "WORK_PHONE",
    pea2.TXTVALUE   AS "MOBILE_PHONE",
    pea3.TXTVALUE   AS "HOME_PHONE",
    pea4.TXTVALUE   AS "EMAIL",
    p.FULLNAME      AS "FULL_NAME",
    p.FIRSTNAME     AS "FIRSTNAME",
    p.LASTNAME      AS "LASTNAME",
    p.CENTER        AS "CENTER_ID",
    p.LAST_MODIFIED AS "ETS",
    p.NICKNAME      AS "NICK_NAME"
FROM
    PERSONS p
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
LEFT JOIN
    PERSON_EXT_ATTRS pea4
ON
    pea4.name ='_eClub_Email'
    AND pea4.PERSONCENTER = p.center
    AND pea4.PERSONID =p.id
WHERE
    p.SEX != 'C'
    AND p.EXTERNAL_ID IS NOT NULL
