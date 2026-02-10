-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.EXTERNAL_ID                      AS "PERSON_ID",
    CAST ( p.CENTER AS VARCHAR(255))   AS "HOME_CENTER_ID",
    CAST ( p.ID AS VARCHAR(255))       AS "HOME_CENTER_PERSON_ID",
    cen.COUNTRY                        AS "HOME_CENTER_COUNTRY_ID",
    cen.SHORTNAME                      AS "HOME_CENTER_SHORT_NAME",
    cea1.TXT_VALUE                     AS "HOME_CENTER_FRANCHISE_ID",
    p.FULLNAME                         AS "FULL_NAME",
    p.FIRSTNAME                        AS "FIRSTNAME",
    p.LASTNAME                         AS "LASTNAME",
    p.ADDRESS1                         AS "ADDRESS1",
    p.ADDRESS2                         AS "ADDRESS2",
    p.ADDRESS3                         AS "ADDRESS3",
    p.COUNTRY                          AS "COUNTRY_ID",
    p.ZIPCODE                          AS "POSTAL_CODE",
    p.CITY                             AS "CITY",
    TO_CHAR(p.BIRTHDATE, 'YYYY-MM-DD') AS "DATE_OF_BIRTH",
    CASE
        WHEN p.SEX = 'M'
        THEN 'MALE'
        WHEN p.SEX = 'F'
        THEN 'FEMALE'
        ELSE 'UNKNOWN'
    END                                                   AS "GENDER",
    BI_DECODE_FIELD ('PERSONS','PERSONTYPE',p.PERSONTYPE) AS "PERSON_TYPE",
    BI_DECODE_FIELD ('PERSONS','STATUS',p.STATUS)         AS "PERSON_STATUS",
    creationDate.TXTVALUE                                 AS "CREATION_DATE",
    TO_CHAR(p.FIRST_ACTIVE_START_DATE, 'YYYY-MM-DD')      AS "FIRST_SUBSCRIPTION_SALE_DATE",
    TO_CHAR(p.LAST_ACTIVE_END_DATE, 'YYYY-MM-DD')         AS "LAST_ACTIVE_END_DATE",                             
    payer.EXTERNAL_ID                                     AS "PAYER_PERSON_ID",
    company.EXTERNAL_ID                                   AS "COMPANY_ID",
    z.COUNTY                                              AS "COUNTY",
    z.PROVINCE                                            AS "STATE",
    cen.TIME_ZONE                                         AS "TIME_ZONE",
    cen.COUNTRY                                           AS "LANGUAGE",
    UPPER(channelEmail.TXTVALUE)                          AS "EMAIL_SERVICE_PERMISSION",
    UPPER(channelSMS.TXTVALUE)                            AS "SMS_SERVICE_PERMISSION",
    UPPER(channelPhone.TXTVALUE)                          AS "PHONE_SERVICE_PERMISSION",
    CASE 
        WHEN length(marketingEmail.TXTVALUE) > 0
        THEN UPPER(marketingEmail.TXTVALUE)                      
        ELSE 'FALSE' 
    END                                                   AS "EMAIL_MARKETING_PERMISSION",
    CASE 
        WHEN length(marketingSMS.TXTVALUE) > 0
        THEN UPPER(marketingSMS.TXTVALUE)                      
        ELSE 'FALSE' 
    END                                                   AS "SMS_MARKETING_PERMISSION",
    CASE 
        WHEN length(marketingPhone.TXTVALUE) > 0
        THEN UPPER(marketingPhone.TXTVALUE)                      
        ELSE 'FALSE' 
    END                                                   AS "PHONE_MARKETING_PERMISSION",
    CASE 
        WHEN preferredChannel.TXTVALUE = 'noChannel'
        THEN ''
        WHEN preferredChannel.TXTVALUE = 'email'
        THEN 'EMAIL'
        WHEN preferredChannel.TXTVALUE = 'sms'
        THEN 'SMS'                     
        ELSE preferredChannel.TXTVALUE 
    END                                                   AS "PREFERRED_CHANNEL_EXERP",    
    TO_CHAR(longToDatetz(p.LAST_MODIFIED,cen.time_zone), 'dd.MM.yyyy HH24:MI:SS') "LAST_UPDATED_EXERP",
    -- For inbound SMS Agillic doesn't support leading '+'
    REPLACE(pea1.TXTVALUE, '+','') AS "WORK_PHONE",
    REPLACE(pea2.TXTVALUE, '+','') AS "MOBILE_PHONE",
    REPLACE(pea3.TXTVALUE, '+','') AS "HOME_PHONE",
    pea4.TXTVALUE                  AS "EMAIL"
FROM
    PERSONS p
JOIN
    CENTERS cen
ON
    p.CENTER = cen.ID
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
-- Permission for service communications
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
AND p.id=channelEmail.PERSONID
AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
AND p.id=channelSMS.PERSONID
AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS channelPhone
ON
    p.center=channelPhone.PERSONCENTER
AND p.id=channelPhone.PERSONID
AND channelPhone.name='_eClub_AllowedChannelPhone'
-- Permission for marketing communications
LEFT JOIN
    PERSON_EXT_ATTRS marketingEmail
ON
    p.center=marketingEmail.PERSONCENTER
AND p.id=marketingEmail.PERSONID
AND marketingEmail.name='AcceptEmailMarketing'
LEFT JOIN
    PERSON_EXT_ATTRS marketingSMS
ON
    p.center=marketingSMS.PERSONCENTER
AND p.id=marketingSMS.PERSONID
AND marketingSMS.name='AcceptSMSMarketing'
LEFT JOIN
    PERSON_EXT_ATTRS marketingPhone
ON
    p.center=marketingPhone.PERSONCENTER
AND p.id=marketingPhone.PERSONID
AND marketingPhone.name='AcceptPhoneMarketing'
-- Preferred channel
LEFT JOIN
    PERSON_EXT_ATTRS preferredChannel
ON
    p.center=preferredChannel.PERSONCENTER
AND p.id=preferredChannel.PERSONID
AND preferredChannel.name='_eClub_DefaultMessaging'
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
LEFT JOIN
    CENTER_EXT_ATTRS cea1
ON
    cea1.name ='FranchiseId'
AND cea1.center_id = cen.id  
    
WHERE
    -- Exclude companies
    p.SEX != 'C'
    -- Exclude Transferred
AND p.external_id IS NOT NULL
    -- Exclude staff members
AND p.PERSONTYPE NOT IN (2,10)