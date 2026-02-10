-- The extract is extracted from Exerp on 2026-02-08
-- If email is empty or if email not empty but allow email is No or empty, include in list. Not staff. Not blacklisted
WITH
     Member AS
     (
         SELECT DISTINCT
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
             
			p.status IN (2)--Active inact temp lead prosp cont
			 AND p.persontype NOT IN (2) --NOT STAFF
             AND c.COUNTRY IN ('DE', 'AT', 'CH')
			AND p.CENTER IN (:Scope)
     )
     
 SELECT DISTINCT
	 p.center||'p'||p.id AS MemberID,
     p.EXTERNAL_ID,
	 p.centerName        AS "Center",
     p.centerId          AS "Center ID",
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
	
     p.FIRSTNAME,
     p.LASTNAME,
     email.TXTVALUE      AS email,
allow_Email.TXTVALUE     AS allow_Email,

     
     p.ADDRESS1,
	p.ADDRESS2,
     p.ZIPCODE,
     p.CITY,
     CASE p.COUNTRY
WHEN 'DE' THEN 'Germany'
ELSE p.COUNTRY
END AS "COUNTRY",
 allow_Letter.TXTVALUE     AS allow_Letter,
allow_SMS.TXTVALUE     AS allow_SMS,
allow_Phone_Call.TXTVALUE     AS allow_Phone,
      
    
                                                                                                                                             
   OPTIN.TXTVALUE                                                                                                                                                              AS "OPTIN",
   OPTIN_Date.TXTVALUE                                                                                                                                                          AS "OPTIN_Date",
   DOI.TXTVALUE                                                                                                                                                        AS "DOI",
   DOI_Date.TXTVALUE                                                                                                                                                    AS "DOI_Date",

p.blacklisted AS "BlackList",
cd.TXTVALUE
AS "create date",

CASE WHEN
p.STATUS IN (1,2,3) THEN 
TO_CHAR(cp.LAST_ACTIVE_END_DATE,'DD-MM-YYYY') 
ELSE 'null' 
END AS "EndedDate",


osd.TXTVALUE AS "JoinDate",
 p.BIRTHDATE,
     p.SEX,

CASE
        WHEN quest.number_answer IS NOT NULL AND q.id IS NOT NULL
         THEN CAST ((xpath('//question[id/text()='|| 2 ||']/options/option[id/text()='|| quest.number_answer ||']/optionText/text()',xmlparse(document convert_from(q.QUESTIONS, 'UTF-8'))))[1] AS VARCHAR(255))
        ELSE NULL
    END               AS "Cancellation Reason 1",
    quest.text_answer AS "Cancellation Reason 2"




 FROM
     Member p
LEFT JOIN
     PERSON_EXT_ATTRS aggregator
 ON
     p.center=aggregator.PERSONCENTER
     AND p.id=aggregator.PERSONID
     AND aggregator.name='AGGREGATOR'

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
     PERSON_EXT_ATTRS allow_SMS
 ON
     p.center=allow_SMS.PERSONCENTER
     AND p.id=allow_SMS.PERSONID
     AND allow_SMS.name='_eClub_AllowedChannelSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Phone_Call
 ON
     p.center=allow_Phone_Call.PERSONCENTER
     AND p.id=allow_Phone_Call.PERSONID
     AND allow_Phone_Call.name='_eClub_AllowedChannelPhone'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Letter
 ON
     p.center=allow_Letter.PERSONCENTER
     AND p.id=allow_Letter.PERSONID
     AND allow_Letter.name='_eClub_AllowedChannelLetter'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Email
 ON
     p.center=allow_Email.PERSONCENTER
     AND p.id=allow_Email.PERSONID
     AND allow_Email.name='_eClub_AllowedChannelEmail'
 LEFT JOIN
     PERSON_EXT_ATTRS NEWSL
 ON
     p.center = NEWSL.PERSONCENTER
     AND p.id = NEWSL.PERSONID
     AND NEWSL.name = '_eClub_IsAcceptingEmailNewsLetters'
 
 
 LEFT JOIN
     PERSON_EXT_ATTRS assigned_email
 ON
     p.center=assigned_email.PERSONCENTER
     AND p.id=assigned_email.PERSONID
     AND assigned_email.name='_eClub_Email'
 
 LEFT JOIN
     PERSON_EXT_ATTRS OPTIN
 ON
     p.center=OPTIN.PERSONCENTER
     AND p.id=OPTIN.PERSONID
     AND OPTIN.name='GDPROPTIN'
 LEFT JOIN
     PERSON_EXT_ATTRS OPTIN_Date
 ON
     p.center=OPTIN_Date.PERSONCENTER
     AND p.id=OPTIN_Date.PERSONID
     AND OPTIN_Date.name='GDPROPTINDATE'
 LEFT JOIN
     PERSON_EXT_ATTRS DOI
 ON
     p.center=DOI.PERSONCENTER
     AND p.id=DOI.PERSONID
     AND DOI.name='GDPRDOUBLEOPTIN'
 LEFT JOIN
     PERSON_EXT_ATTRS DOI_Date
 ON
     p.center=DOI_Date.PERSONCENTER
     AND p.id=DOI_Date.PERSONID
     AND DOI_Date.name='GDPRDOUBLEOPTINdate'

LEFT JOIN			
                PERSON_EXT_ATTRS cd			
                ON			
                   p.center = cd.PERSONCENTER			
                AND p.id = cd.PERSONID 			
                AND cd.name = 'CREATION_DATE'	
LEFT JOIN
    PERSON_EXT_ATTRS osd
ON
    p.center = osd.PERSONCENTER
    AND p.id = osd.PERSONID
	AND osd.name = 'OriginalStartDate'

JOIN
	SUBSCRIPTIONS subs
ON
	subs.owner_center = p.CENTER 
	AND subs.OWNER_ID = p.id
	
JOIN
SUBSCRIPTIONTYPES subt
ON
subt.center = subs.center
AND subt.id = subs.subscriptiontype_id

LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = subs.SUBSCRIPTIONTYPE_CENTER
    AND prod.id = subs.SUBSCRIPTIONTYPE_ID

LEFT JOIN
       PERSONS cp
        ON
            cp.center = subs.OWNER_CENTER
        AND cp.ID = subs.OWNER_ID

LEFT JOIN
    (
        SELECT
            qaa.center,
            qaa.id,
            qa1.text_answer,
            qa2.number_answer,
            qc.questionnaire
        FROM
            questionnaire_answer qaa
        JOIN
            questionnaire_campaigns qc
        ON
            qc.id = qaa.questionnaire_campaign_id
        LEFT JOIN
            QUESTION_ANSWER qa1
        ON
            qa1.ANSWER_CENTER =qaa.CENTER
            AND qa1.ANSWER_ID=qaa.ID
            AND qa1.answer_subid = qaa.subid
            AND qa1.QUESTION_ID = 1
        LEFT JOIN
            QUESTION_ANSWER qa2
        ON
            qa2.ANSWER_CENTER =qaa.CENTER
            AND qa2.ANSWER_ID=qaa.ID
            AND qa2.answer_subid = qaa.subid
            AND qa2.QUESTION_ID = 2
        WHERE
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    questionnaire_answer qaa2
                WHERE
                    qaa2.center = qaa.center
                    AND qaa2.id = qaa.id
                    AND qaa2.log_time > qaa.log_time) )quest
ON
    quest.center = p.center
    AND quest.id = p.id
LEFT JOIN
    QUESTIONNAIRES q
ON
    q.id = quest.questionnaire




WHERE
cp.LAST_ACTIVE_END_DATE >= (:EnddateFROM)
AND cp.LAST_ACTIVE_END_DATE <= (:EnddateTO)
AND p.blacklisted IN (0)
AND p.ADDRESS1 NOT IN ('DELETED', 'deleted', 'Deleted', 'X', 'x')
AND subs.sub_state NOT IN (8)--not cancelled
AND ((email.TXTVALUE IS NULL) or (email.TXTVALUE IS NOT NULL and allow_Email.TXTVALUE NOT IN ('true')))
AND p.ZIPCODE IS NOT NULL
AND p.ADDRESS1 IS NOT NULL


