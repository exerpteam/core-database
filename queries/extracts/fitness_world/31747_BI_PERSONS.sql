-- This is the version from 2026-02-05
--  
SELECT
    p.EXTERNAL_ID                    "PERSON_ID",
    CAST ( p.CENTER AS VARCHAR(255)) "HOME_CENTER_ID",
    CAST ( p.ID AS VARCHAR(255))     "HOME_CENTER_PERSON_ID",
    CASE
        WHEN dup_of.center != p.center
            OR dup_of.id != p.id
        THEN dup_of.EXTERNAL_ID
        ELSE NULL
    END                 AS             "DUPLICATE_OF_PERSON_ID",
    salutation.TXTVALUE AS             "TITLE",
    p.FULLNAME                         "FULL_NAME",
    p.FIRSTNAME                        "FIRSTNAME",
    p.LASTNAME                         "LASTNAME",
    p.COUNTRY                          "COUNTRY_ID",
    p.ZIPCODE                          "POSTAL_CODE",
    p.CITY AS                          "CITY",
    TO_CHAR(p.BIRTHDATE, 'YYYY-MM-DD') "DATE_OF_BIRTH",
    CASE
        WHEN p.SEX = 'M'
        THEN 'MALE'
        WHEN p.SEX = 'F'
        THEN 'FEMALE'
        ELSE 'UNKNOWN'
    END                                                   AS "GENDER",
    BI_DECODE_FIELD ('PERSONS','PERSONTYPE',p.PERSONTYPE) AS "PERSON_TYPE",
    BI_DECODE_FIELD ('PERSONS','STATUS',p.STATUS)         AS "PERSON_STATUS",
    creationDate.TXTVALUE                                    "CREATION_DATE",
    payer.EXTERNAL_ID                                        "PAYER_PERSON_ID",
    company.EXTERNAL_ID                                      "COMPANY_ID",
    z.COUNTY                     AS                                              "COUNTY",
    z.PROVINCE                   AS                                              "STATE",
    UPPER(channelEmail.TXTVALUE) AS                                              "CAN_EMAIL",
    UPPER(channelSMS.TXTVALUE)   AS                                              "CAN_SMS",
    p.CENTER                     AS                                              "CENTER_ID",
    REPLACE(TO_CHAR(p.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    PERSONS p
JOIN
    PERSONS dup_of
ON
    dup_of.CENTER = p.CURRENT_PERSON_CENTER
    AND dup_of.ID = p.CURRENT_PERSON_ID
LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.RELATIVECENTER = p.CENTER
    AND op_rel.RELATIVEID = p.ID
    AND op_rel.RTYPE = 12
    AND op_rel.STATUS < 3
LEFT JOIN
    persons payer
ON
    payer.CENTER = op_rel.CENTER
    AND payer.ID = op_rel.ID
LEFT JOIN
    RELATIVES com_rel
ON
    com_rel.RELATIVECENTER = p.CENTER
    AND com_rel.RELATIVEID = p.ID
    AND com_rel.RTYPE = 2
    AND com_rel.STATUS < 3
LEFT JOIN
    persons company
ON
    company.CENTER = com_rel.CENTER
    AND company.ID = com_rel.ID
LEFT JOIN
    PERSON_EXT_ATTRS creationDate
ON
    creationDate.personcenter = p.center
    AND creationDate.personid = p.id
    AND creationDate.name = 'CREATION_DATE'
LEFT JOIN
    ZIPCODES z
ON
    z.COUNTRY = p.COUNTRY
    AND z.ZIPCODE = p.ZIPCODE
    AND z.CITY = p.CITY
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
    AND p.id=channelSMS.PERSONID
    AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
    AND p.id=channelEmail.PERSONID
    AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center=salutation.PERSONCENTER
    AND p.id=salutation.PERSONID
    AND salutation.name='_eClub_Salutation'
WHERE
    p.SEX != 'C'
    -- Exclude Transferred
    AND p.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND p.id = p.TRANSFERS_CURRENT_PRS_ID
    AND p.LAST_MODIFIED BETWEEN (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint
     AND (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint