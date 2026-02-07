
WITH
    PARAMS AS
    (
        SELECT
            c.id,
            datetolongc(TO_CHAR(DATE_TRUNC('day' , CURRENT_DATE -1), 'YYYY-MM-DD HH24:MI'),c.id) AS
            STARTTIME ,
            datetolongc(TO_CHAR(DATE_TRUNC('day' , CURRENT_DATE), 'YYYY-MM-DD HH24:MI'),c.id) AS
            ENDTIME
        FROM
            centers c
    )
SELECT
    p.external_id           AS "EXTERNAL ID",
    p.center                AS "PERSON CENTER",
    p.center || 'p' || p.id AS "PERSON ID",
    email.txtvalue          AS "EMAIL",
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
    END                        AS "STATUS",
    originalStartDate.txtvalue AS "ORIGINAL_START_DATE",
    originalStartDate.txtvalue AS "ANNIVERSARY",
    periodFeeCoDate.txtvalue   AS "PERIOD_FEE_CO_DATE",
    (
        CASE
            WHEN p.CENTER=14
            THEN coFeeHAM.TXTVALUE
            WHEN p.CENTER=2
            THEN coFeeBMS.TXTVALUE
            ELSE coFeeAll.TXTVALUE
        END)                                      AS "CHARGE_CO_FEE",
    gdprOptin.txtvalue                            AS "GDPR_OPTIN",
    gdprOptinDate.txtvalue                        AS "GDPR_OPTIN_DATE",
    gdprDoubleOptinDate.txtvalue                  AS "GDPR_DOUBLE_OPTIN_DATE",
    TO_CHAR(p.last_active_end_date, 'YYYY-MM-DD') AS "LAST_ACTIVE_END_DATE",
    channelEmail.txtvalue                         AS "ALLOW_CHANNEL_EMAIL",
    channelLetter.txtvalue                        AS "ALLOW_CHANNEL_LETTER"
FROM
    PERSONS p
JOIN
    PERSON_EXT_ATTRS gdprOptin
ON
    p.center=gdprOptin.PERSONCENTER
AND p.id=gdprOptin.PERSONID
JOIN
    PARAMS
ON
    params.id = p.center
AND gdprOptin.name='GDPROPTIN'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
AND p.id=email.PERSONID
AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS channelLetter
ON
    p.center=channelLetter.PERSONCENTER
AND p.id=channelLetter.PERSONID
AND channelLetter.name='_eClub_AllowedChannelLetter'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
AND p.id=channelEmail.PERSONID
AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS gdprOptinDate
ON
    p.center=gdprOptinDate.PERSONCENTER
AND p.id=gdprOptinDate.PERSONID
AND gdprOptinDate.name='GDPROPTINDATE'
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
AND p.status != 4
AND GREATEST(email.last_edit_time,channelEmail.last_edit_time,channelLetter.last_edit_time,
    gdprOptin.last_edit_time,gdprOptinDate.last_edit_time,gdprDoubleOptinDate.last_edit_time,
    periodFeeCoDate.last_edit_time, periodFeeCoDate.last_edit_time ,coFeeBMS.last_edit_time ,
    coFeeHAM.last_edit_time ,coFeeAll.last_edit_time ,originalStartDate.last_edit_time) BETWEEN
    params.STARTTIME AND params.ENDTIME