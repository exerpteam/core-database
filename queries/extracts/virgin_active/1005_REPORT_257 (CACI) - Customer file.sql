SELECT
    p.UNIQUE_KEY "MembersID",
    p.CENTER || 'p' || p.ID "SysMemberID",
    TO_CHAR(p.DATE_OF_BIRTH,'YYYYmmDD') "Birth Date",
    p.SALUTATION "Title",
    replace(replace(replace(replace(p.FIRST_NAME,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Forename",
    replace(replace(replace(replace(p.LAST_NAME,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Surname",
    replace(replace(replace(replace(p.ADDRESS_1,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Home Property",
    replace(replace(replace(replace(p.ADDRESS_1,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Home Street",
    replace(replace(replace(replace(p.ADDRESS_1,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Home Locality",
    replace(replace(replace(replace(p.CITY,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Home Town",
    p.POSTAL_CODE "Billing Postcode",
    replace(replace(replace(replace(p.EMAIL,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Home Email Address",
    replace(replace(replace(replace(p.HOME_PHONE,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Home Telephone Number",
    replace(replace(replace(replace(p.CELLULAR_PHONE,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Mobile Telephone Number",
    replace(replace(replace(replace(comp.LASTNAME,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Work Company",
    comp.ZIPCODE "Work Postcode",
    nvl2(allowEmail.PERSONCENTER,'Y','N') "Email for Marketing",
    'N/A' "Fax for Marketing",
    nvl2(allowLetter.PERSONCENTER,'Y','N') "Mails for Marketing",
    nvl2(allowSMS.PERSONCENTER,'Y','N') "SMS for Marketing",
    nvl2(allowPhone.PERSONCENTER,'Y','N') "Telephones for Marketing",
    nvl2(extMark.PERSONCENTER,'Y','N') "Third party Flag",
    p.GENDER "Gender",
    c.NAME "Club",
    TO_CHAR(p.CREATION_TIME,'YYYYmmDD') "Join Date",
    TO_CHAR(longToDateC(MAX(cin.CHECKIN_TIME),p.center),'YYYYmmDD') "Last Visit",
    COUNT(cin.CHECKIN_CENTER) "Visits",
    '?' "Status",
    '?' "Lapsed Date",
    '?' "Source Status",
    replace(replace(replace(replace(comp.LASTNAME,chr(10),' '),chr(13),' '),';',' '),'"','''')  "Company",
    null "Paid",
    '?' "Earliest End Date",
    null "Segmentation",
    '?' "Leaving Reason",
    '?' "Source Description",
    '?' "Contract Type",
    '?' "Pru Health"
FROM
    PERSONS_VW p
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

JOIN CENTERS c
ON
    c.ID = p.CENTER
LEFT JOIN CHECKINS cin
ON
    cin.PERSON_CENTER = p.CENTER
    AND cin.PERSON_ID = p.ID
GROUP BY
    p.UNIQUE_KEY ,
    p.CENTER,
    p.ID,
    TO_CHAR(p.DATE_OF_BIRTH,'YYYYmmDD') ,
    p.SALUTATION ,
    p.FIRST_NAME ,
    p.LAST_NAME ,
    p.ADDRESS_1 ,
    p.ADDRESS_1 ,
    p.ADDRESS_1 ,
    p.CITY ,
    p.POSTAL_CODE ,
    p.EMAIL ,
    p.HOME_PHONE ,
    p.CELLULAR_PHONE ,
    comp.LASTNAME ,
    comp.ZIPCODE ,
    nvl2(extMark.PERSONCENTER,'Y','N') ,
    p.GENDER ,
    c.NAME ,
    TO_CHAR(p.CREATION_TIME,'YYYYmmDD') ,
    comp.LASTNAME,
    nvl2(allowEmail.PERSONCENTER,'Y','N') ,
    nvl2(allowEmail.PERSONCENTER,'Y','N') ,
    nvl2(allowSMS.PERSONCENTER,'Y','N') ,
	nvl2(allowLetter.PERSONCENTER,'Y','N'),
    nvl2(allowPhone.PERSONCENTER,'Y','N')