SELECT
    p.EXTERNAL_ID                AS "PERSON_ID",
    p.NATIONAL_ID                AS "NATIONAL_ID",
    p.RESIDENT_ID                AS "RESIDENT_ID",
    p.CENTER                     AS "CENTER_ID",
    pea_number.txtvalue          AS "PASSPORT_NUMBER",
    pea_country.txtvalue         AS "PASSPORT_ISSUING_COUNTRY",
    pea_expirydate.txtvalue      AS "PASSPORT_EXPIRATION_DATE",
    p.SSN                        AS "SSN",
    p.LAST_MODIFIED              AS "ETS"
FROM
    PERSONS p
LEFT JOIN
    PERSON_EXT_ATTRS pea_number
ON  pea_number.PERSONCENTER = p.center
    AND pea_number.PERSONID = p.id
    AND pea_number.NAME = '_eClub_PassportNumber'
LEFT JOIN
    PERSON_EXT_ATTRS pea_country
ON  pea_country.PERSONCENTER = p.center
    AND pea_country.PERSONID = p.id
    AND pea_country.NAME = '_eClub_PassportIssuanceCountry'
LEFT JOIN
    PERSON_EXT_ATTRS pea_ExpiryDate
ON  pea_ExpiryDate.PERSONCENTER = p.center
    AND pea_ExpiryDate.PERSONID = p.id
    AND pea_ExpiryDate.NAME = '_eClub_PassportExpiryDate'        
WHERE
    p.SEX != 'C'
    AND p.EXTERNAL_ID IS NOT NULL
