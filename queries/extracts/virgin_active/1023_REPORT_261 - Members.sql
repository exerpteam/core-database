-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT distinct
     "RecordID",
     "SourceID",
     "MembershipNumber",
     "MemNoC",
     "Swipe",
     "HomeClub",
     "Status",
     "MemPKID",
     "Address1",
     "Address2",
     "Address3",
     "Address4",
     "Address5",
     "PostCode",
     "HomePhone",
     "MobilePhone",
     "WorkPhone",
     "Email",
     "NoContact",
     "MktMail",
     "MktEmail",
     "MktPhone",
     "MktText",
     "JoinDate",
     "TermDate",
     "DOB",
     "Gender",
     "Title",
     "FirstNames",
     "LastName",
     "Initials",
     "CorporateID",
     "SubDescription",
         "PersonType"
 FROM
     (
         SELECT DISTINCT
             /* INT */
             p.UNIQUE_KEY "RecordID",
             /* Small int */
             10 "SourceID",
             /* VARCHAR(20) */
             p.CENTER || 'p' || p.ID "MembershipNumber",
             /* VARCHAR(20) */
             p.UNIQUE_KEY "MemNoC",
             /* VARCHAR(25) */
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ei.IDENTITY,chr(10),' '),chr(13),' '),';',' '),'"',''''),chr(32),'') "Swipe",
             /* small int */
             p.CENTER "HomeClub",
             /* VARCHAR(20) */
             p.STATUS "Status",
             /* VARCHAR(36) */
             MemPKID.TXTVALUE "MemPKID",
             REPLACE(REPLACE(REPLACE(REPLACE(p.ADDRESS_1,chr(10),' '),chr(13),' '),';',' '),'"','''') "Address1",
             REPLACE(REPLACE(REPLACE(REPLACE(p.ADDRESS_2,chr(10),' '),chr(13),' '),';',' '),'"','''') "Address2",
             REPLACE(REPLACE(REPLACE(REPLACE(pa.ADDRESS3,chr(10),' '),chr(13),' '),';',' '),'"','''') "Address3",
             NULL "Address4",
             NULL "Address5",
             p.POSTAL_CODE "PostCode",
             REPLACE(REPLACE(REPLACE(REPLACE(p.HOME_PHONE,chr(10),' '),chr(13),' '),';',' '),'"','''') "HomePhone",
             REPLACE(REPLACE(REPLACE(REPLACE(p.CELLULAR_PHONE,chr(10),' '),chr(13),' '),';',' '),'"','''') "MobilePhone",
             workPhone.TXTVALUE "WorkPhone",
             REPLACE(REPLACE(REPLACE(REPLACE(p.EMAIL,chr(10),' '),chr(13),' '),';',' '),'"','''') "Email",
             NULL "NoContact",
             CASE WHEN allowLetter.PERSONCENTER IS NOT NULL THEN 1 ELSE 0 END "MktMail",
             CASE WHEN allowEmail.PERSONCENTER IS NOT NULL THEN 1 ELSE 0 END "MktEmail",
             CASE WHEN allowPhone.PERSONCENTER IS NOT NULL THEN 1 ELSE 0 END "MktPhone",
             CASE WHEN allowSMS.PERSONCENTER IS NOT NULL THEN 1 ELSE 0 END "MktText",
             /* Need common definition for this */
             perCreation.TXTVALUE "JoinDate",
             s.END_DATE "TermDate",
             p.DATE_OF_BIRTH "DOB",
             CASE p.GENDER WHEN 'MALE' THEN 'M' WHEN 'FEMALE' THEN 'F' ELSE 'UNDEFINED' END "Gender",
             p.SALUTATION "Title",
             REPLACE(REPLACE(REPLACE(REPLACE(p.FIRST_NAME,chr(10),' '),chr(13),' '),';',' '),'"','''') "FirstNames",
             REPLACE(REPLACE(REPLACE(REPLACE(p.LAST_NAME,chr(10),' '),chr(13),' '),';',' '),'"','''') "LastName",
             SUBSTR(p.FIRST_NAME,1,1) || '' || SUBSTR(p.LAST_NAME,1,1) "Initials",
             COALESCE(comp.EXTERNAL_ID,'0') "CorporateID",
             ROW_NUMBER() OVER (PARTITION BY p.UNIQUE_KEY ORDER BY s.STATE ASC,s.START_DATE DESC) row_nbr,
             /* Need common definition for this */
             REPLACE(REPLACE(REPLACE(REPLACE( prod.NAME ,chr(10),' '),chr(13),' '),';',' '),'"','''') "SubDescription",
                         pa.PERSONTYPE "PersonType"
         FROM
             PERSONS_VW p
             /* Fix this in the view */
         JOIN PERSONS pa
         ON
             pa.CENTER = p.CENTER
             AND pa.ID = p.ID
         LEFT JOIN SUBSCRIPTIONS s
         ON
             s.OWNER_CENTER = p.CENTER
             AND s.OWNER_ID = p.id
             AND s.STATE IN (2,4,8)
         LEFT JOIN PRODUCTS prod
         ON
             prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
             AND prod.ID = s.SUBSCRIPTIONTYPE_ID
         LEFT JOIN ENTITYIDENTIFIERS ei
         ON
             ei.REF_CENTER = p.CENTER
             AND ei.REF_ID = p.ID
             AND ei.REF_TYPE = 1
             AND ei.STOP_TIME IS NULL
             AND ei.ENTITYSTATUS = 1
                         AND ei.IDMETHOD = 2
         JOIN CENTERS c
         ON
             c.ID = p.CENTER and c.country = 'GB'
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
         LEFT JOIN PERSON_EXT_ATTRS MemNoC
         ON
             MemNoC.PERSONCENTER = p.CENTER
             AND MemNoC.PERSONID = p.ID
             AND MemNoC.NAME = 'COMPANY_AGREEMENT_EMPLOYEE_NUMBER'
         LEFT JOIN PERSON_EXT_ATTRS MemPKID
         ON
             MemPKID.PERSONCENTER = p.CENTER
             AND MemPKID.PERSONID = p.ID
             AND MemPKID.NAME = '_eClub_OldSystemPersonId'
         LEFT JOIN PERSON_EXT_ATTRS perCreation
         ON
             perCreation.PERSONCENTER = p.CENTER
             AND perCreation.PERSONID = p.ID
             AND perCreation.NAME = 'CREATION_DATE'
         LEFT JOIN PERSON_EXT_ATTRS workPhone
         ON
             workPhone.PERSONCENTER = p.CENTER
             AND workPhone.PERSONID = p.ID
             AND workPhone.NAME = '_eClub_PhoneWork'
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
     ) t1
 WHERE
     ROW_NBR = 1
