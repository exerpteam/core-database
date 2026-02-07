WITH
     Member AS
     (
         SELECT
             p.*,
             c.name AS centerName,
             c.id   AS centerId
         FROM
             PERSONS p
         JOIN
             CENTERS c
         ON
             c.id = p.CENTER
         WHERE
             p.STATUS NOT IN (8)
             AND c.COUNTRY IN ('DE')
     )
     ,
     v_task AS
     (
         SELECT
             t.PERSON_CENTER,
             t.PERSON_ID,
             MAX(t.CREATION_TIME) CREATION_TIME
         FROM
             TASKS t
         JOIN
             Member mem
         ON
             mem.center = t.PERSON_CENTER
             AND mem.id = t.PERSON_id
         GROUP BY
             t.PERSON_CENTER,
             t.PERSON_ID
     )
 SELECT
     p.EXTERNAL_ID,
     p.FIRSTNAME,
     p.LASTNAME,
     p.center||'p'||p.id AS MemberID,
     p.centerName        AS "Center Name",
     p.centerId          AS "Center ID",
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
     CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARY INACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END AS "STATUS",
     
     CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS "PERSONTYPE",
     
     t.ASIGNEE_CENTER ||'p'||t.ASIGNEE_ID                                                                                                                                            AS "Staff ID Assigned to task",
     emp.FULLNAME                                                                                                                                                                    AS "Staff Name Assigned to task",
     ts.NAME                                                                                                                                                                         AS "Step",
     TO_CHAR(t.FOLLOW_UP,'yyyy-MM-dd')                                                                                                                                               AS "Follow up",
	keepmeid.TXTVALUE                                                                                                                                                              AS KEEPMEID,
     allow_channel_Email.TXTVALUE                                                                                                                                                    AS allow_channel_Email,
     allow_channel_Letter.TXTVALUE                                                                                                                                                      allow_channel_Letter,
     allow_channel_SMS.TXTVALUE                                                                                                                                                         allow_channel_SMS,
     allow_channel_Phone.TXTVALUE                                                                                                                                                       allow_channel_Phone,
     THIRD.TXTVALUE                                                                                                                                                                  AS Allow_Third_party,
     NEWSL.TXTVALUE                                                                                                                                                                  AS Allow_Newsletter,
     staff.TXTVALUE                                                                                                                                                                  AS "Sales Staff",
 sales_name.TXTVALUE                                                                                                                                                                  AS "Sales Name",
     sales_email.TXTVALUE                                                                                                                                                         AS "Sales Staff Email",
     assigned_email.TXTVALUE                                                                                                                                                         AS "Assigned To Email",
     gdprOptin.TXTVALUE                                                                                                                                                              AS GDPR_OPTIN,
     gdprOptinDate.TXTVALUE                                                                                                                                                          AS GDPR_OPTIN_DATE,
     gdprDoubleOptin.TXTVALUE                                                                                                                                                        AS GDPR_DOUBLE_OPTIN,
     gdprDoubleOptinDate.TXTVALUE                                                                                                                                                    AS GDPR_DOUBLE_OPTIN_DATE
 FROM
     Member p
LEFT JOIN
     PERSON_EXT_ATTRS keepmeid
 ON
     p.center=keepmeid.PERSONCENTER
     AND p.id=keepmeid.PERSONID
     AND keepmeid.name='KEEPMEID'
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
     PERSON_EXT_ATTRS staff
 ON
     p.center=staff.PERSONCENTER
     AND p.id=staff.PERSONID
     AND staff.name='Sales_Staff'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_channel_SMS
 ON
     p.center=allow_channel_SMS.PERSONCENTER
     AND p.id=allow_channel_SMS.PERSONID
     AND allow_channel_SMS.name='_eClub_AllowedChannelSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_channel_Phone
 ON
     p.center=allow_channel_Phone.PERSONCENTER
     AND p.id=allow_channel_Phone.PERSONID
     AND allow_channel_Phone.name='_eClub_AllowedChannelPhone'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_channel_Letter
 ON
     p.center=allow_channel_Letter.PERSONCENTER
     AND p.id=allow_channel_Letter.PERSONID
     AND allow_channel_Letter.name='_eClub_AllowedChannelLetter'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_channel_Email
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
     v_task mt
 ON
     mt.PERSON_CENTER = p.center
     AND mt.PERSON_ID = p.id
 LEFT JOIN
     TASKS t
 ON
     t.PERSON_CENTER = p.center
     AND t.PERSON_ID = p.id
     AND t.CREATION_TIME =mt.CREATION_TIME
 LEFT JOIN
     PERSONS emp
 ON
     emp.center = t.ASIGNEE_CENTER
     AND emp.id = t.ASIGNEE_ID
 LEFT JOIN
     TASK_STEPS ts
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
     PERSON_EXT_ATTRS sales_name
 ON
     staff2.center=sales_name.PERSONCENTER
     AND staff2.id=sales_name.PERSONID
     AND sales_name.name='FIRSTNAME'

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

