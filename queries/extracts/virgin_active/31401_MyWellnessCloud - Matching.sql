SELECT
        p.FIRSTNAME AS "firstName",
        p.LASTNAME AS "lastName",
        email.TXTVALUE AS "email",
        p.SEX AS "gender",
        TO_CHAR(p.BIRTHDATE,'yyyy-MM-dd')  AS "birthDate",
        phoneHome.TXTVALUE AS "phoneNumber",
        phoneMobile.TXTVALUE AS "mobilePhoneNumber",
        p.ZIPCODE AS "zipCode",
        p.EXTERNAL_ID AS "memberId"        
FROM PERSONS p
LEFT JOIN PERSON_EXT_ATTRS email ON p.CENTER = email.PERSONCENTER AND p.ID = email.PERSONID AND email.NAME='_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS phoneHome ON p.CENTER = phoneHome.PERSONCENTER AND p.ID = phoneHome.PERSONID AND phoneHome.NAME='_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS phoneMobile ON p.CENTER = phoneMobile.PERSONCENTER AND p.ID = phoneMobile.PERSONID AND phoneMobile.NAME='_eClub_PhoneSMS'
WHERE p.COUNTRY='IT'
AND p.STATUS NOT IN (4,5,7,8)
AND p.CENTER IN ($$scope$$)