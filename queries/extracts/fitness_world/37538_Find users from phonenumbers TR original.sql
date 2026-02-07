-- This is the version from 2026-02-05
--  
SELECT
    mobile.PERSONCENTER || 'p' || mobile.PERSONID AS "Member Id",
    mobile.txtvalue                               AS "Phone Number",
    email.txtvalue                                AS "Email"
FROM
    PERSON_EXT_ATTRS mobile
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    mobile.PERSONCENTER=email.PERSONCENTER
    AND mobile.PERSONID=email.PERSONID
    AND email.name='_eClub_Email'
WHERE
    mobile.name='_eClub_PhoneSMS'
    AND mobile.txtvalue IS NOT NULL
    AND (REPLACE(mobile.txtvalue, '+45', '') IN ($$PhoneNumbers$$) OR  mobile.txtvalue IN ($$PhoneNumbers$$))