

SELECT
    p.external_id                      AS "EXTERNAL ID",
    p.center || 'p' || p.id            AS "PERSON ID",
    p.firstname                        AS "FIRSTNAME",
    p.lastname                         AS "LASTNAME",
    p.center                           AS "CENTER ID",
    email.txtvalue                     AS "EMAIL",
    mobile.txtvalue                    AS "PHONE",
    p.ADDRESS1                         AS "ADDRESS1",
    p.ADDRESS2                         AS "ADDRESS2",
    p.zipcode                          AS "ZIPCODE",
    p.city                             AS "CITY",
    TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS "BIRTHDATE",
    p.sex                              AS "SEX",
    CASE
        WHEN p.STATUS = 0
        THEN 'LEAD'
        WHEN p.STATUS = 1
        THEN 'ACTIVE'
        WHEN p.STATUS = 2
        THEN 'INACTIVE'
        WHEN p.STATUS = 3
        THEN 'TEMPORARYINACTIVE'
        WHEN p.STATUS = 4
        THEN 'TRANSFERED'
        WHEN p.STATUS = 5
        THEN 'DUPLICATE'
        WHEN p.STATUS = 6
        THEN 'PROSPECT'
        WHEN p.STATUS = 7
        THEN 'DELETED'
        WHEN p.STATUS = 8
        THEN 'ANONYMIZED'
        WHEN p.STATUS = 9
        THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "STATUS",
    CASE
        WHEN p.PERSONTYPE = 0
        THEN 'PRIVATE'
        WHEN p.PERSONTYPE = 1
        THEN 'STUDENT'
        WHEN p.PERSONTYPE = 2
        THEN 'STAFF'
        WHEN p.PERSONTYPE = 3
        THEN 'FRIEND'
        WHEN p.PERSONTYPE = 4
        THEN 'CORPORATE'
        WHEN p.PERSONTYPE = 5
        THEN 'ONEMANCORPORATE'
        WHEN p.PERSONTYPE = 6
        THEN 'FAMILY'
        WHEN p.PERSONTYPE = 7
        THEN 'SENIOR'
        WHEN p.PERSONTYPE = 8
        THEN 'GUEST'
        ELSE 'UNKNOWN'
    END                          AS "PERSONTYPE",
    channelEmail.txtvalue        AS "ALLOW_CHANNEL_EMAIL",
    channelLetter.txtvalue       AS "ALLOW_CHANNEL_LETTER",
    channelSMS.txtvalue          AS "ALLOW_CHANNEL_SMS",
    channelPhone.txtvalue        AS "ALLOW_CHANNEL_PHONE",
    gdprOptin.txtvalue           AS "GDPR_OPTIN",
    gdprOptinDate.txtvalue       AS "GDPR_OPTIN_DATE",
    gdprDoubleOptin.txtvalue     AS "GDPR_DOUBLE_OPTIN",
    gdprDoubleOptinDate.txtvalue AS "GDPR_DOUBLE_OPTIN_DATE",
    periodFeeCoDate.txtvalue     AS "PERIOD_FEE_CO_DATE",
    (
        CASE
            WHEN p.CENTER=14
            THEN coFeeHAM.TXTVALUE
            WHEN p.CENTER=2
            THEN coFeeBMS.TXTVALUE
            ELSE coFeeAll.TXTVALUE
        END)                                      AS "CHARGE_CO_FEE",
    originalStartDate.txtvalue                    AS "ANNIVERSARY",
    originalStartDate.txtvalue                    AS "ORIGINAL_START_DATE",
    TO_CHAR(p.last_active_end_date, 'YYYY-MM-DD') AS "LAPS DATE"
FROM
    PERSONS p
JOIN
    PERSON_EXT_ATTRS gdprOptin
ON
    p.center=gdprOptin.PERSONCENTER
AND p.id=gdprOptin.PERSONID
AND gdprOptin.name='GDPROPTIN'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
AND p.id=email.PERSONID
AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
AND p.id=mobile.PERSONID
AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
AND p.id=channelEmail.PERSONID
AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS channelLetter
ON
    p.center=channelLetter.PERSONCENTER
AND p.id=channelLetter.PERSONID
AND channelLetter.name='_eClub_AllowedChannelLetter'
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
LEFT JOIN
    PERSON_EXT_ATTRS gdprOptinDate
ON
    p.center=gdprOptinDate.PERSONCENTER
AND p.id=gdprOptinDate.PERSONID
AND gdprOptinDate.name='GDPROPTINDATE'
LEFT JOIN
    PERSON_EXT_ATTRS gdprDoubleOptin
ON
    p.center=gdprDoubleOptin.PERSONCENTER
AND p.id=gdprDoubleOptin.PERSONID
AND gdprDoubleOptin.name='GDPRDOUBLEOPTIN'
LEFT JOIN
    PERSON_EXT_ATTRS gdprDoubleOptinDate
ON
    p.center=gdprDoubleOptinDate.PERSONCENTER
AND p.id=gdprDoubleOptinDate.PERSONID
AND gdprDoubleOptinDate.name='GDPRDOUBLEOPTINdate'
LEFT JOIN
    PERSON_EXT_ATTRS periodFeeCoDate
ON
    p.center=periodFeeCoDate.PERSONCENTER
AND p.id=periodFeeCoDate.PERSONID
AND periodFeeCoDate.name IN ('BODYSCANFEEDATE',
                             'COFEEDATEAT',
                             'COFEEDATECH')
LEFT JOIN
    PERSON_EXT_ATTRS coFeeBMS
ON
    coFeeBMS.PERSONCENTER = p.CENTER
AND coFeeBMS.PERSONID = p.ID
AND coFeeBMS.NAME = 'ChargeCOFee'
LEFT JOIN
    PERSON_EXT_ATTRS coFeeHAM
ON
    coFeeHAM.PERSONCENTER = p.CENTER
AND coFeeHAM.PERSONID = p.ID
AND coFeeHAM.NAME = 'CHARGECOFEE'
LEFT JOIN
    PERSON_EXT_ATTRS coFeeAll
ON
    coFeeAll.PERSONCENTER = p.CENTER
AND coFeeAll.PERSONID = p.ID
AND coFeeAll.NAME = 'CHARGE_CO_FEE'
LEFT JOIN
    PERSON_EXT_ATTRS originalStartDate
ON
    p.center=originalStartDate.PERSONCENTER
AND p.id=originalStartDate.PERSONID
AND originalStartDate.name='OriginalStartDate'
WHERE
    p.center IN ($$Scope$$)
AND gdprOptin.txtvalue = 'true'