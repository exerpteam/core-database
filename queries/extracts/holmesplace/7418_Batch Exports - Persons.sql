-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.EXTERNAL_ID,
    p.FIRSTNAME,
    p.LASTNAME,
    p.center||'p'||p.id AS MemberID,
    c.name              AS "center name",
    c.ID                AS "center ID",
    email.TXTVALUE      AS email,
    p.ADDRESS1,
    p.ADDRESS2,
    p.ADDRESS3,
    p.ZIPCODE,
    p.CITY,
    p.COUNTRY,
    mobile.TXTVALUE AS "Mobile phone",
    home.TXTVALUE   AS "Home Phone",
    p.BIRTHDATE,
    p.SEX,
    DECODE (p.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS STATUS,
    DECODE ( p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                        AS PERSONTYPE,
    t.ASIGNEE_CENTER ||'p'||t.ASIGNEE_ID                                                                                                                                            AS "Staff ID Assigned to task",
    emp.FULLNAME                                                                                                                                                                    AS "Staff Name Assigned to task",
    ts.NAME                                                                                                                                                                         AS "Step",
    TO_CHAR(t.FOLLOW_UP,'yyyy-MM-dd')                                                                                                                                               AS "Follow up",
    allow_channel_Email.TXTVALUE                                                                                                                                                    AS allow_channel_Email,
    allow_channel_Letter.TXTVALUE                                                                                                                                                      allow_channel_Letter,
    allow_channel_SMS.TXTVALUE                                                                                                                                                         allow_channel_SMS,
    allow_channel_Phone.TXTVALUE                                                                                                                                                       allow_channel_Phone,
    THIRD.TXTVALUE                                                                                                                                                                  AS Allow_Third_party,
    NEWSL.TXTVALUE                                                                                                                                                                  AS Allow_Newsletter,
    staff.TXTVALUE                                                                                                                                                                  AS "Sales Staff",
    sales_email.TXTVALUE                                                                                                                                                            AS "Sales Staff Email",
    assigned_email.TXTVALUE                                                                                                                                                         AS "Assigned To Email",
    gdprOptin.TXTVALUE   AS GDPR_OPTIN,
    gdprOptinDate.TXTVALUE  AS GDPR_OPTIN_DATE,
    gdprDoubleOptin.TXTVALUE   AS GDPR_DOUBLE_OPTIN,
    gdprDoubleOptinDate.TXTVALUE  AS GDPR_DOUBLE_OPTIN_DATE
FROM
    HP.PERSONS p
JOIN
    HP.CENTERS c
ON
    c.id = p.CENTER
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    hp.PERSON_EXT_ATTRS staff
ON
    p.center=staff.PERSONCENTER
    AND p.id=staff.PERSONID
    AND staff.name='Sales_Staff'
LEFT JOIN
    hp.PERSON_EXT_ATTRS allow_channel_SMS
ON
    p.center=allow_channel_SMS.PERSONCENTER
    AND p.id=allow_channel_SMS.PERSONID
    AND allow_channel_SMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    hp.PERSON_EXT_ATTRS allow_channel_Phone
ON
    p.center=allow_channel_Phone.PERSONCENTER
    AND p.id=allow_channel_Phone.PERSONID
    AND allow_channel_Phone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    hp.PERSON_EXT_ATTRS allow_channel_Letter
ON
    p.center=allow_channel_Letter.PERSONCENTER
    AND p.id=allow_channel_Letter.PERSONID
    AND allow_channel_Letter.name='_eClub_AllowedChannelLetter'
LEFT JOIN
    hp.PERSON_EXT_ATTRS allow_channel_Email
ON
    p.center=allow_channel_Email.PERSONCENTER
    AND p.id=allow_channel_Email.PERSONID
    AND allow_channel_Email.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS NEWSL
ON
    p.center = NEWSL.PersonCenter
    AND p.id = NEWSL.PersonId
    AND NEWSL.Name = '_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS THIRD
ON
    p.center = THIRD.PersonCenter
    AND p.id = THIRD.PersonId
    AND THIRD.Name = 'eClub_IsAcceptingThirdPartyOffers'
LEFT JOIN
    (
        SELECT
            t.PERSON_CENTER,
            t.PERSON_ID,
            MAX(t.CREATION_TIME) CREATION_TIME
        FROM
            HP.TASKS t
        GROUP BY
            t.PERSON_CENTER,
            t.PERSON_ID) mt
ON
    mt.PERSON_CENTER = p.center
    AND mt.PERSON_ID = p.id
LEFT JOIN
    HP.TASKS t
ON
    t.PERSON_CENTER = p.center
    AND t.PERSON_ID = p.id
    AND t.CREATION_TIME =mt.CREATION_TIME
LEFT JOIN
    HP.PERSONS emp
ON
    emp.center = t.ASIGNEE_CENTER
    AND emp.id = t.ASIGNEE_ID
LEFT JOIN
    HP.TASK_STEPS ts
ON
    ts.id = t.STEP_ID
LEFT JOIN
    PERSON_EXT_ATTRS assigned_email
ON
    p.center=assigned_email.PERSONCENTER
    AND p.id=assigned_email.PERSONID
    AND assigned_email.name='_eClub_Email'
LEFT JOIN
    persons staff2
ON
    staff2.center||'p'||staff2.id = staff.TXTVALUE
LEFT JOIN
    PERSON_EXT_ATTRS sales_email
ON
    staff2.center=sales_email.PERSONCENTER
    AND staff2.id=sales_email.PERSONID
    AND sales_email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS gdprOptin
ON
    p.center=gdprOptin.PERSONCENTER
    AND p.id=gdprOptin.PERSONID
    AND gdprOptin.name='GDPROPTIN'
LEFT JOIN
    PERSON_EXT_ATTRS gdprOptinDate
ON
    p.center=gdprOptinDate.PERSONCENTER
    AND p.id=gdprOptinDate.PERSONID
    AND gdprOptinDate.name='GDPROPTINDATE'
LEFT JOIN
    PERSON_EXT_ATTRS gdprDoubleOptin
ON
    p.center=gdprDoubleOptin.PERSONCENTER
    AND p.id=gdprDoubleOptin.PERSONID
    AND gdprDoubleOptin.name='GDPRDOUBLEOPTIN'
LEFT JOIN
    PERSON_EXT_ATTRS gdprDoubleOptinDate
ON
    p.center=gdprDoubleOptinDate.PERSONCENTER
    AND p.id=gdprDoubleOptinDate.PERSONID
    AND gdprDoubleOptinDate.name='GDPRDOUBLEOPTINdate'
WHERE
    p.STATUS NOT IN (8) 
--    AND p.PERSONTYPE != 2 -- see https://clublead.zendesk.com/agent/tickets/81255