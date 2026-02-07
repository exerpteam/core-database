SELECT
    p.UNIQUE_KEY "RecordID",
    p.UNIQUE_KEY "MemNo",
    '?' "SourceID",
    /* We need a clear definition of this for cases > 1 membership or addon usage, family membership etc */
    '?' "MembershipNumber",
    'N/A' "MemNoC",
    ei.IDENTITY "Swipe",
    p.CENTER "HomeClub",
    p.STATUS "Status",
    '?' "Category",
    'N/A' "MemPKID",
    p.ADDRESS_1 "Address1",
    p.ADDRESS_2 "Address2",
    'N/A' "Address3",
    'N/A' "Address4",
    'N/A' "Address5",
    p.POSTAL_CODE "PostCode",
    p.HOME_PHONE "HomePhone",
    p.CELLULAR_PHONE "MobilePhone",
    'N/A' "WorkPhone",
    p.EMAIL "Email",
    '?' "NoContact",
    nvl2(allowLetter.PERSONCENTER,'Y','N') "MktMail",
    nvl2(allowEmail.PERSONCENTER,'Y','N') "MktEmail",
    nvl2(allowPhone.PERSONCENTER,'Y','N') "MktPhone",
    nvl2(allowSMS.PERSONCENTER,'Y','N') "MktText",
    /* Need common definition for this */
    '?' "JoinDate",
    '?' "TermDate",
    p.DATE_OF_BIRTH "DOB",
    p.SALUTATION "Title",
    p.GENDER "Gender",
    p.FIRST_NAME "FirstNames",
    p.LAST_NAME "LastName",
    SUBSTR(p.FIRST_NAME,1,1) || '' || SUBSTR(p.LAST_NAME,1,1) "Initials",
    comp.EXTERNAL_ID "CorporateID",
    /* Need common definition for this */
    '?' "SubDescription"
FROM
    PERSONS_VW p
LEFT JOIN ENTITYIDENTIFIERS ei
ON
    ei.REF_CENTER = p.CENTER
    AND ei.REF_ID = p.ID
    AND ei.REF_TYPE = 1
    AND ei.STOP_TIME IS NULL
    AND ei.ENTITYSTATUS = 1
JOIN CENTERS c
ON
    c.ID = p.CENTER
LEFT JOIN PERSON_EXT_ATTRS extMark
ON
    extMark.PERSONCENTER = p.CENTER
    AND extMark.PERSONID = p.ID
    AND extMark.NAME = '_eClub_IsAcceptingThirdPartyOffers'
    AND extMark.TXTVALUE = 'true'
LEFT JOIN PERSON_EXT_ATTRS allowSMS
ON
    allowSMS.PERSONCENTER = p.CENTER
    AND allowSMS.PERSONID = p.ID
    AND allowSMS.NAME = '_eClub_AllowedChannelSMS'
    AND allowSMS.TXTVALUE = 'true'
LEFT JOIN PERSON_EXT_ATTRS allowPhone
ON
    allowPhone.PERSONCENTER = p.CENTER
    AND allowPhone.PERSONID = p.ID
    AND allowPhone.NAME = '_eClub_AllowedChannelPhone'
    AND allowPhone.TXTVALUE = 'true'
LEFT JOIN PERSON_EXT_ATTRS allowEmail
ON
    allowEmail.PERSONCENTER = p.CENTER
    AND allowEmail.PERSONID = p.ID
    AND allowEmail.NAME = '_eClub_AllowedChannelEmail'
    AND allowEmail.TXTVALUE = 'true'
LEFT JOIN PERSON_EXT_ATTRS allowLetter
ON
    allowLetter.PERSONCENTER = p.CENTER
    AND allowLetter.PERSONID = p.ID
    AND allowLetter.NAME = '_eClub_AllowedChannelLetter'
    AND allowLetter.TXTVALUE = 'true'
LEFT JOIN RELATIVES rel
ON
    rel.CENTER = p.CENTER
    AND rel.ID = p.ID
    AND rel.RTYPE = 3
    AND rel.STATUS = 1
LEFT JOIN PERSONS comp
ON
    comp.CENTER = rel.RELATIVECENTER
    AND comp.ID = rel.RELATIVEID