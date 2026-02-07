SELECT
    i1.REGION,
    i1.HOME_CLUB,
    i1.NAME,
    i1.MEMBERSHIP_NUMBER,
    i1.FIRST_NAME,
    i1.LAST_NAME,
    i1.PACKAGE_TYPE,
    i1.EMAIL_ADDRESS,
    i1.EMAIL_VALID,
    i1.MEMBER_STATUS,
    i1.MOBILE_PHONE,
    i1.MOBILE_NUMBER_VALID,
    i1.JOIN_DATE,
    i1.OPT_IN_MAIL,
    i1.OPT_IN_EMAIL,
    i1.OPI_IN_TEL,
    i1.OPT_IN_SMS,
    longToDateC(MAX(atts.LAST_EDIT_TIME),i1.HOME_CLUB) DATE_UPDATED
FROM
    (
        SELECT DISTINCT
            p.CENTER,
            p.ID,
            a.NAME Region,
            p.CENTER home_Club,
            c.NAME,
            s.CENTER || 'ss' || s.ID membership_number,
            p.FIRSTNAME FIRST_NAME,
            p.LASTNAME LAST_NAME,
            pg.NAME package_type,
            EMail.TXTVALUE EMAIL_ADDRESS,
            'true' EMAIL_VALID,
            DECODE (p.STATUS , 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') MEMBER_STATUS,
            PhoneSMS.TXTVALUE MOBILE_PHONE,
            'true' MOBILE_NUMBER_VALID,
            p.FIRST_ACTIVE_START_DATE JOIN_DATE,
            AllLetter.TXTVALUE OPT_IN_MAIL,
            AllEMail.TXTVALUE OPT_IN_EMAIL,
            AllPhone.TXTVALUE OPI_IN_TEL,
            AllSMS.TXTVALUE OPT_IN_SMS
        FROM
            PERSONS p
        JOIN CENTERS c
        ON
            c.id = p.CENTER
        JOIN AREA_CENTERS ac
        ON
            ac.CENTER = p.CENTER
        JOIN AREAS a
        ON
            a.ID = ac.AREA
        LEFT JOIN SUBSCRIPTIONS s
        ON
            s.OWNER_CENTER = p.CENTER
            AND s.OWNER_ID = p.ID
        LEFT JOIN PRODUCTS prod
        ON
            prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
            AND prod.ID = s.SUBSCRIPTIONTYPE_ID
        LEFT JOIN PRODUCT_GROUP pg
        ON
            pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
        LEFT JOIN PERSON_EXT_ATTRS AllEMail
        ON
            AllEMail.PERSONCENTER = p.CENTER
            AND AllEMail.PERSONID = p.ID
            AND AllEMail.NAME = '_eClub_AllowedChannelEmail'
        LEFT JOIN PERSON_EXT_ATTRS AllLetter
        ON
            AllLetter.PERSONCENTER = p.CENTER
            AND AllLetter.PERSONID = p.ID
            AND AllLetter.NAME = '_eClub_AllowedChannelLetter'
        LEFT JOIN PERSON_EXT_ATTRS AllPhone
        ON
            AllPhone.PERSONCENTER = p.CENTER
            AND AllPhone.PERSONID = p.ID
            AND AllPhone.NAME = '_eClub_AllowedChannelPhone'
        LEFT JOIN PERSON_EXT_ATTRS AllSMS
        ON
            AllSMS.PERSONCENTER = p.CENTER
            AND AllSMS.PERSONID = p.ID
            AND AllSMS.NAME = '_eClub_AllowedChannelSMS'
        LEFT JOIN PERSON_EXT_ATTRS EMail
        ON
            EMail.PERSONCENTER = p.CENTER
            AND EMail.PERSONID = p.ID
            AND EMail.NAME = '_eClub_Email'
        LEFT JOIN PERSON_EXT_ATTRS PhoneSMS
        ON
            PhoneSMS.PERSONCENTER = p.CENTER
            AND PhoneSMS.PERSONID = p.ID
            AND PhoneSMS.NAME = '_eClub_PhoneSMS'
        WHERE
            p.center IN (:scope)
    )
    i1
LEFT JOIN PERSON_EXT_ATTRS atts
ON
    atts.PERSONCENTER = i1.center
    AND atts.PERSONID = i1.id
    AND atts.NAME IN ('_eClub_AllowedChannelLetter','_eClub_BillingNumber','_eClub_Comment','_eClub_DefaultMessaging','_eClub_InvoiceAddress1','_eClub_InvoiceCity','_eClub_InvoiceCoName','_eClub_InvoiceCountry','_eClub_InvoiceZipCode','_eClub_Salutation','ACCEPTING_EMAIL_NEWS_LETTERS','ACCEPTING_THIRD_PARTY_OFFERS','ADDRESS_1','ADDRESS_2','ADDRESS_3','ALLOWED_CHANNEL_EMAIL','ALLOWED_CHANNEL_PHONE','ALLOWED_CHANNEL_SMS','BIRTHDATE','CITY','CO_NAME','COUNTRY','E_MAIL','FIRST_NAME','HOME_PHONE','LAST_NAME','MIDDLE_NAME','MOB_PHONE','SEX','SSN','WORK_PHONE','ZIP_CODE')
GROUP BY
    i1.CENTER,
    i1.ID,
    i1.REGION,
    i1.HOME_CLUB,
    i1.NAME,
    i1.MEMBERSHIP_NUMBER,
    i1.FIRST_NAME,
    i1.LAST_NAME,
    i1.PACKAGE_TYPE,
    i1.EMAIL_ADDRESS,
    i1.EMAIL_VALID,
    i1.MEMBER_STATUS,
    i1.MOBILE_PHONE,
    i1.MOBILE_NUMBER_VALID,
    i1.JOIN_DATE,
    i1.OPT_IN_MAIL,
    i1.OPT_IN_EMAIL,
    i1.OPI_IN_TEL,
    i1.OPT_IN_SMS