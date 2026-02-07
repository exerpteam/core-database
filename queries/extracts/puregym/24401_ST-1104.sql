SELECT DISTINCT
    c.SHORTNAME "Home Club",
    p.FULLNAME "Name",
    prod.NAME  "Membership",
    'Agents Warning' "Event Description",
    INITCAP(TO_CHAR(SYSDATE,'DD MON YYYY HH24:MI:SS')) "Event Created Date",
    /*Always empty*/
    '' "Event Resolved Date",
    'System Administrator Administrator' "UserName",
    PhoneHome.TXTVALUE                   "HomeTelNo",
    'No' "Terms Exist",
    DECODE(AllowedChannelPhone.TXTVALUE,'TRUE','Yes','FALSE','No') "Marketing ByTelephone",
    DECODE(AllowedChannelLetter.TXTVALUE,'TRUE','Yes','FALSE','No') "Marketing ByPost",
    DECODE(AllowedChannelEmail.TXTVALUE,'TRUE','Yes','FALSE','No') "Marketing ByEmail",
    DECODE(AllowedChannelSMS.TXTVALUE,'TRUE','Yes','FALSE','No') "Marketing ByText",
    p.CENTER || 'p' || p.ID "Member No",
    TO_CHAR(cc.AMOUNT,'L99G999D99MI', 'NLS_NUMERIC_CHARACTERS = '', ''           
NLS_CURRENCY = ''£'' ') "Outstanding",
    Salutation.TXTVALUE                                                                                   "Title",
    p.FIRSTNAME                                                                                           "FirstName",
    p.LASTNAME                                                                                            "LastName",
    p.ADDRESS1                                                                                            "HomeAddress1",
    p.ADDRESS2                                                                                            "HomeAddress2",
    p.ADDRESS3                                                                                            "HomeAddress3",
    /* Looks like the city should be here */
    p.CITY    "HomeAddress4",
    p.ZIPCODE "PostalCode",
    'Lapsed' "Member Status",
    s.START_DATE "Agreement Start",
    Email.TXTVALUE                                             "eMail",
    TO_CHAR(p.BIRTHDATE,'DD/MM/YYYY')                          "DOB",
    TO_CHAR(least(s.BINDING_END_DATE,s.END_DATE),'DD/MM/YYYY') "RenewalDate",
    prod.NAME "Price Type",
    NULL "Final Bill Date",
    TO_CHAR(s.BINDING_PRICE,'L99G999D99MI', 'NLS_NUMERIC_CHARACTERS = '', ''           
NLS_CURRENCY = ''£'' ') "Cycle Fees",
    TO_CHAR(longToDateC(MAX(cin.CHECKIN_TIME) over (partition BY p.CENTER,p.ID),p.CENTER),'DD/MM/YYYY') "Last Visit",
    PhoneSMS.TXTVALUE  "Mobile",
    PhoneWork.TXTVALUE "WorkTelNo"
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.ID = s.OWNER_ID
LEFT JOIN
    CHECKINS cin
ON
    cin.PERSON_CENTER = p.CENTER
    AND cin.PERSON_ID = p.ID
JOIN
    PRODUCTS prod
ON
    prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND prod.ID = s.SUBSCRIPTIONTYPE_ID
JOIN
    CENTERS c
ON
    c.ID = p.CENTER
JOIN
    CASHCOLLECTIONCASES cc
ON
    cc.PERSONCENTER = p.CENTER
    AND cc.PERSONID = p.ID
    AND cc.CLOSED = 0
    AND cc.MISSINGPAYMENT = 1
LEFT JOIN
    PERSON_EXT_ATTRS PhoneHome
ON
    PhoneHome.personcenter = p.center
    AND PhoneHome.personid = p.id
    AND PhoneHome.name = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS AllowedChannelEmail
ON
    AllowedChannelEmail.personcenter = p.center
    AND AllowedChannelEmail.personid = p.id
    AND AllowedChannelEmail.name = '_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS AllowedChannelLetter
ON
    AllowedChannelLetter.personcenter = p.center
    AND AllowedChannelLetter.personid = p.id
    AND AllowedChannelLetter.name = '_eClub_AllowedChannelLetter'
LEFT JOIN
    PERSON_EXT_ATTRS AllowedChannelPhone
ON
    AllowedChannelPhone.personcenter = p.center
    AND AllowedChannelPhone.personid = p.id
    AND AllowedChannelPhone.name = '_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS AllowedChannelSMS
ON
    AllowedChannelSMS.personcenter = p.center
    AND AllowedChannelSMS.personid = p.id
    AND AllowedChannelSMS.name = '_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS IsAcceptingEmailNewsLetters
ON
    IsAcceptingEmailNewsLetters.personcenter = p.center
    AND IsAcceptingEmailNewsLetters.personid = p.id
    AND IsAcceptingEmailNewsLetters.name = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS IsAcceptingThirdPartyOffers
ON
    IsAcceptingThirdPartyOffers.personcenter = p.center
    AND IsAcceptingThirdPartyOffers.personid = p.id
    AND IsAcceptingThirdPartyOffers.name = 'eClubIsAcceptingThirdPartyOffers'
LEFT JOIN
    PERSON_EXT_ATTRS PhoneHome
ON
    PhoneHome.personcenter = p.center
    AND PhoneHome.personid = p.id
    AND PhoneHome.name = '_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS PhoneSMS
ON
    PhoneSMS.personcenter = p.center
    AND PhoneSMS.personid = p.id
    AND PhoneSMS.name = '_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS Salutation
ON
    Salutation.personcenter = p.center
    AND Salutation.personid = p.id
    AND Salutation.name = '_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS Email
ON
    Email.personcenter = p.center
    AND Email.personid = p.id
    AND Email.name = '_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS PhoneWork
ON
    PhoneWork.personcenter = p.center
    AND PhoneWork.personid = p.id
    AND PhoneWork.name = '_eClub_PhoneWork'
WHERE
    p.CENTER = 2
    AND p.ID = 38
    /* should be some specific center */
    and p.CENTER in ($$scope$$)
    and prod.GLOBALID in ('DD_TIER_1000','DD_TIER_777')
    and s.STATE in ($$subscription_state$$)
