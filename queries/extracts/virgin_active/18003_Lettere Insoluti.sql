-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.CENTER || 'p' || p.ID                        MEMBER_ID,
    p.FULLNAME                                     MEMBER_NAME,
    TRUNC(months_between(SYSDATE, p.BIRTHDATE)/12) MEMBER_AGE,
    prod.NAME                                      SUB_TYPE,
    /*prod*/
    TRUNC(longToDate(s.CREATION_TIME)) SUB_SALES_DATE,
    s.START_DATE                       SUB_START_DATE,
    s.BINDING_END_DATE                 SUB_BINDING_END_DATE,
    s.BINDING_PRICE                    SUB_PRICE_UNIT,
    /* proce */
    ExtEmail.TXTVALUE                                                                       MEMBER_EMAIL,
    nvl2(ExtPhoneSMS.TXTVALUE,ExtPhoneSMS.TXTVALUE,PERSON_EXT_ATTRS.ExtSalutation.TXTVALUE) MEMBER_PHONE,
    nvl2(pp.CENTER,pp.CENTER || 'p' || pp.ID,p.CENTER || 'p' || p.ID)                       PAYER_PERSON_ID,
    /*P-number */
    ExtOldSystemPersonId.TXTVALUE PAYER_LEGACY_ID,
    /* old system id */
    ExtSalutation.TXTVALUE                                                                                         PAYER_SALUTATION,
    nvl2(pp.CENTER,pp.FIRSTNAME,p.FIRSTNAME)                                                                       PAYER_FIRST_NAME,
    nvl2(pp.CENTER,pp.LASTNAME,p.LASTNAME)                                                                         PAYER_LAST_NAME,
    nvl2(pp.CENTER,pp.ADDRESS1,p.ADDRESS1)                                                                         PAYER_ADDRESS_1,
    nvl2(pp.CENTER,pp.ADDRESS2,p.ADDRESS2)                                                                         PAYER_ADDRESS_2,
    nvl2(pp.CENTER,pp.ADDRESS3,p.ADDRESS3)                                                                         PAYER_ADDRESS_3,
    nvl2(pp.CENTER,pp.ZIPCODE,p.ZIPCODE)                                                                           PAYER_POSTCODE,
    nvl2(pp.CENTER,pp.CITY,p.CITY)                                                                                 PAYER_CITY,
    nvl2(pp.CENTER,pp.BIRTHDATE,p.BIRTHDATE)                                                                       PAYER_DOB,
    nvl2(pp.CENTER,TRUNC(months_between(SYSDATE, pp.BIRTHDATE)/12),TRUNC(months_between(SYSDATE, p.BIRTHDATE)/12)) PAYER_AGE,
    ExtPhoneSMS.TXTVALUE                                                                                           PAYER_PHONE_MOBILE,
    ExtPhoneHome.TXTVALUE                                                                                          PAYER_PHONE_HOME,
    ExtEmail.TXTVALUE                                                                                              PAYER_E_MAIL,
    cc.AMOUNT                                                                                                      PAYER_TOTAL_DEBT,
    cc.STARTDATE                                                                                                   PAYER_DEBT_START_DATE,
    pc.SHORTNAME                                                                                                   PAYER_CENTER_NAME
FROM
    PERSONS p
JOIN
    CENTERS c
ON
    c.id = p.CENTER
    AND c.COUNTRY = 'IT'
LEFT JOIN
    RELATIVES rel
ON
    rel.RELATIVECENTER = p.CENTER
    AND rel.RELATIVEID = p.ID
LEFT JOIN
    PERSONS pp
ON
    pp.CENTER = rel.CENTER
    AND pp.ID = rel.ID
LEFT JOIN
    CASHCOLLECTIONCASES cc
ON
    ((
            pp.CENTER IS NOT NULL
            AND cc.PERSONCENTER = pp.CENTER
            AND cc.PERSONID = pp.ID)
        OR (
            rel.CENTER IS NULL
            AND cc.PERSONCENTER = p.CENTER
            AND cc.PERSONID = p.ID) )
LEFT JOIN
    CENTERS pc
ON
    ((
            pp.CENTER IS NOT NULL
            AND pc.ID = pp.CENTER)
        OR (
            pp.CENTER IS NULL
            AND pc.ID = p.CENTER ) )
LEFT JOIN
    PERSON_EXT_ATTRS ExtSalutation
ON
    ExtSalutation.personcenter = p.center
    AND ExtSalutation.personid = p.id
    AND ExtSalutation.name = '_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS ExtPhoneHome
ON
    ExtPhoneHome.personcenter = p.center
    AND ExtPhoneHome.personid = p.id
    AND ExtPhoneHome.name = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS ExtPhoneSMS
ON
    ExtPhoneSMS.personcenter = p.center
    AND ExtPhoneSMS.personid = p.id
    AND ExtPhoneSMS.name = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS ExtEmail
ON
    ExtEmail.personcenter = p.center
    AND ExtEmail.personid = p.id
    AND ExtEmail.name = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS ExtOldSystemPersonId
ON
    ExtOldSystemPersonId.PERSONCENTER = p.CENTER
    AND ExtOldSystemPersonId.PERSONID = p.ID
    AND ExtOldSystemPersonId.NAME = '_eClub_OldSystemPersonId'
LEFT JOIN
    SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.ID
LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
WHERE
    AND cc.CENTER IS NOT NULL 
    and p.CENTER in ($$scope$$)
    and s.END_DATE IS NULL
	and cc.AMOUNT IS NOT NULL