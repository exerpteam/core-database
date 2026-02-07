WITH
    elig_subs AS
    (
        SELECT
            old_subscription_center AS center ,
            old_subscription_id     AS id,
            owner_center ,
            owner_id,
            last_end_date
        FROM
            (
                SELECT
                    sc.*,
                    lsc.effect_date AS last_end_date,
                    s.owner_center,
                    s.owner_id,
                    row_number() over (partition BY s.center,s.id ORDER BY lsc.change_time DESC) AS
                    rnk
                FROM
                    subscriptions s
                JOIN
                    subscription_change sc
                ON
                    sc.old_subscription_center = s.center
                AND sc.old_subscription_id = s.id
                JOIN
                    subscriptiontypes st
                ON
                    st.center=s.subscriptiontype_center
                AND st.id = s.subscriptiontype_id
                LEFT JOIN
                    subscription_change lsc
                ON
                    lsc.old_subscription_center = s.center
                AND lsc.old_subscription_id = s.id
                AND lsc.change_time < sc.change_time
                AND ( lsc.cancel_time IS NULL
                    OR  lsc.cancel_time > 1680307200000) -- april 1st
                WHERE
                    sc.change_time BETWEEN 1680307200000 AND 1682899200000 --april 1st until may 1st
                AND sc.type = 'END_DATE'
                AND sc.effect_date = '2023-04-30'
                AND sc.cancel_time IS NULL
                AND s.center = 207
                AND sc.employee_center = 200
                AND sc.employee_id = 7403) t1
        WHERE
            rnk = 1
    )
SELECT DISTINCT
	p.external_id,
    center.id                          AS centerId,
    center.NAME                        AS centerName,
    p.center || 'p' || p.id            AS personid,
    personCreation.txtvalue            AS personCreationDate,
    salutation.txtvalue                AS title,
    p.firstname                        AS firstname,
    p.MIDDLENAME                       AS middlename,
    p.lastname                         AS lastname,
    p.ssn                              AS ssn,
    TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS birthdate,
    p.sex                              AS gender,
    p.ADDRESS1                         AS AddressLine1,
    p.ADDRESS2                         AS AddressLine2,
    p.ADDRESS3                         AS AddressLine3,
    p.zipcode                          AS zipcode,
    p.city                             AS city,
    zipcode.county                     AS county,
    p.country                          AS country,
    home.txtvalue                      AS homephone,
    workphone.txtvalue                 AS workphone,
    mobile.txtvalue                    AS mobilephone,
    email.txtvalue                     AS email,
    personcomment.txtvalue             AS personcomment,
    CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        ELSE 'UNKNOWN'
    END AS PersonType,
    CASE channelEmail.txtvalue
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS ALLOWEDCHANNELEMAIL,
    CASE channelLetter.txtvalue
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS ALLOWEDCHANNELLETTER,
    CASE channelPhone.txtvalue
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS ALLOWEDCHANNELPHONE,
    CASE channelSMS.txtvalue
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS ALLOWEDCHANNELSMS,
    CASE emailNewsLetter.txtvalue
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS ALLOWEDCHANNELNEWSLETTERS,
    CASE thirdPartyOffers.txtvalue
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS ALLOWEDCHANNELTHIRDPARTYOFFERS,
    CASE
        WHEN comp.CENTER IS NOT NULL
        THEN comp.CENTER||'p'||comp.ID
        ELSE NULL
    END                AS RelatedToCompanyID,
    comp.lastname      AS RelatedToCompanyName,
    cag.NAME           AS RelatedToCompanyAgreement,
    cash_ar.balance    AS CashAccountBalance,
    payment_ar.balance AS PaymentAccountBalance,
    CASE ei.IDMETHOD
        WHEN 1
        THEN 'BARCODE'
        WHEN 2
        THEN 'MAGNETIC_CARD'
        WHEN 3
        THEN 'SSN'
        WHEN 4
        THEN 'RFID_CARD'
        WHEN 5
        THEN 'PIN'
        WHEN 6
        THEN 'ANTI DROWN'
        WHEN 7
        THEN 'QRCODE'
        ELSE 'UNKNOWN'
    END                                                 AS MembercardType,
    ei.IDENTITY                                         AS membercardid,
    ch.name                                             AS clearinghouse_name,
    pa.REF                                              AS dd_referenceid, --KIDSwap ref
    pa.CLEARINGHOUSE_REF                        AS dd_contractid, -- Adyen token clearinghouse ref
    pa.expiration_date                                  AS dd_expiration_date,
    pa.BANK_REGNO                                          dd_bankreg,
    pa.BANK_BRANCH_NO                                   AS dd_bankbranch,
    pa.BANK_ACCNO                                       AS dd_bankaccount,
    pa.BANK_ACCOUNT_HOLDER                                 dd_accountholder,
    pa.EXTRA_INFO                                       AS dd_extrainfo,
    pa.IBAN                                                dd_iban,
    TO_CHAR(longtodate(pa.CREATION_TIME), 'YYYY-MM-DD') AS dd_creationdate,
    CASE pa.STATE
        WHEN 1
        THEN 'CREATED'
        WHEN 2
        THEN 'SENT'
        WHEN 3
        THEN 'FAILED'
        WHEN 4
        THEN 'OK'
        WHEN 5
        THEN 'ENDED BY DEBITOR''S BANK'
        WHEN 6
        THEN 'ENDED BY THE CLEARING HOUSE'
        WHEN 7
        THEN 'ENDED BY DEBITOR'
        WHEN 8
        THEN 'SHAL BE CANCELLED'
        WHEN 9
        THEN 'END REQUEST SENT'
        WHEN 10
        THEN 'ENDED BY CREDITOR'
        WHEN 11
        THEN 'NO AGREEMENT WITH DEBITOR'
        WHEN 12
        THEN 'DEPRECATED'
        WHEN 13
        THEN 'NOT NEEDED'
        WHEN 14
        THEN 'INCOMPLETE'
        WHEN 15
        THEN 'TRANSFERRED'
        ELSE 'UNKNOWN'
    END AS dd_state,
    pa.REQUESTS_SENT,
    CASE
        WHEN op.center IS NOT NULL
        THEN op.FIRSTNAME || ' ' || op.LASTNAME
        ELSE NULL
    END    AS OTHERPAYERNAME,
    op.ssn AS OTHERPAYERSSN,
    CASE
        WHEN op.CENTER IS NOT NULL
        THEN op.center || 'p' || op.id
        ELSE ''
    END AS OTHERPAYERID,
    CASE
        WHEN pay_for.PAYER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS IS_OTHER_PAYER,
    CASE
        WHEN pay_for.PAYER_CENTER IS NOT NULL
        THEN pay_for.center||'p'||pay_for.id
        ELSE ''
    END AS PAY_FOR
FROM
    persons p
LEFT JOIN
    elig_subs s
ON
    s.owner_center = p.center
AND s.owner_id = p.id
JOIN
    CENTERS center
ON
    p.center = center.id
LEFT JOIN
    zipcodes zipcode
ON
    zipcode.country = p.country
AND zipcode.zipcode = p.zipcode
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center=salutation.PERSONCENTER
AND p.id=salutation.PERSONID
AND salutation.name='_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS personCreation
ON
    p.center=personCreation.PERSONCENTER
AND p.id=personCreation.PERSONID
AND personCreation.name='CREATION_DATE'
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
AND p.id=home.PERSONID
AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
AND p.id=mobile.PERSONID
AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS workphone
ON
    p.center=workphone.PERSONCENTER
AND p.id=workphone.PERSONID
AND workphone.name='_eClub_PhoneWork'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
AND p.id=email.PERSONID
AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS personcomment
ON
    p.center=personcomment.PERSONCENTER
AND p.id=personcomment.PERSONID
AND personcomment.name='_eClub_Comment'
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
    PERSON_EXT_ATTRS channelPhone
ON
    p.center=channelPhone.PERSONCENTER
AND p.id=channelPhone.PERSONID
AND channelPhone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
AND p.id=channelSMS.PERSONID
AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS emailNewsLetter
ON
    p.center=emailNewsLetter.PERSONCENTER
AND p.id=emailNewsLetter.PERSONID
AND emailNewsLetter.name='_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS thirdPartyOffers
ON
    p.center=thirdPartyOffers.PERSONCENTER
AND p.id=thirdPartyOffers.PERSONID
AND thirdPartyOffers.name='_eClub_IsAcceptingThirdPartyOffers'
LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = p.center
AND payment_ar.CUSTOMERID = p.id
AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER=p.center
AND cash_ar.CUSTOMERID=p.id
AND cash_ar.AR_TYPE = 1
LEFT JOIN
    RELATIVES comp_rel
ON
    comp_rel.center=p.center
AND comp_rel.id=p.id
AND comp_rel.RTYPE = 3
AND comp_rel.STATUS < 3
LEFT JOIN
    COMPANYAGREEMENTS cag
ON
    cag.center= comp_rel.RELATIVECENTER
AND cag.id=comp_rel.RELATIVEID
AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN
    persons comp
ON
    comp.center = cag.center
AND comp.id=cag.id
LEFT JOIN
    ENTITYIDENTIFIERS ei
ON
    ei.REF_CENTER = p.CENTER
AND ei.REF_ID = p.id
AND ei.entitystatus = 1
LEFT JOIN
    PAYMENT_ACCOUNTS paymentaccount
ON
    paymentaccount.center = payment_ar.center
AND paymentaccount.id = payment_ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    paymentaccount.ACTIVE_AGR_CENTER = pa.center
AND paymentaccount.ACTIVE_AGR_ID = pa.id
AND paymentaccount.ACTIVE_AGR_SUBID = pa.subid
LEFT JOIN
    clearinghouses ch
ON
    ch.id = pa.clearinghouse
LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.relativecenter=p.center
AND op_rel.relativeid=p.id
AND op_rel.RTYPE = 12
AND op_rel.STATUS < 3
LEFT JOIN
    PERSONS op
ON
    op.center = op_rel.center
AND op.id = op_rel.id
LEFT JOIN
    ACCOUNT_RECEIVABLES otherPayerAR
ON
    otherPayerAR.CUSTOMERCENTER = op.center
AND otherPayerAR.CUSTOMERID = op.id
AND otherPayerAR.AR_TYPE = 4
    -- other payer
LEFT JOIN
    (
        SELECT DISTINCT
            rel.center AS PAYER_CENTER,
            rel.id     AS PAYER_ID,
            mem.center,
            mem.id
        FROM
            PERSONS mem
        JOIN
            elig_subs sub
        ON
            mem.center = sub.OWNER_CENTER
        AND mem.id = sub.OWNER_ID
        JOIN
            RELATIVES rel
        ON
            rel.RELATIVECENTER = mem.center
        AND rel.RELATIVEID = mem.id
        AND rel.RTYPE = 12
        AND rel.STATUS < 3
        and rel.center = 207 ) pay_for
ON
    pay_for.payer_center = p.center
AND pay_for.payer_id = p.id

WHERE
    (s.center IS NOT NULL
    OR  pay_for.center IS NOT NULL)
AND p.sex != 'C'
    