-- The extract is extracted from Exerp on 2026-02-08
--  
 -- Parameters: fromDate(DATE),toDate(DATE),scope(SCOPE)
 SELECT pid
      , age
      , firstname
      , lastname
      , last_checkin
      , old_system_id
      , center_name
      , termination_type
      , ddi_stopped
      , subscription_end_date
      , debt_case_start
      , debt_case_amount
      , subscription_type
      , product_group
      , email
      , mobil
      , join_Date
      , leaving_reason "Reason for leaving"
 FROM
 (
 SELECT
     /*+ NO_BIND_AWARE */
     DISTINCT p.CENTER || 'p' || p.id pid,
     floor(months_between(TRUNC(CURRENT_TIMESTAMP),p.BIRTHDATE)/12) age,
     p.FIRSTNAME,
     p.LASTNAME,
     longToDate(MAX(ci.CHECKIN_TIME) over (PARTITION BY p.EXTERNAL_ID)) last_checkin,
     oldId.TXTVALUE old_system_id,
     c.SHORTNAME center_name,
     CASE
         WHEN FIRST_VALUE(s.END_DATE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) IS NOT NULL
         THEN 'Subscription ended'
         WHEN ccc.AMOUNT IS NOT NULL
         THEN 'Debt case'
         ELSE 'DDI case'
     END AS TERMINATION_TYPE,
     CASE
         WHEN msAgreement.STARTDATE IS NOT NULL
         THEN TO_CHAR(msAgreement.STARTDATE, 'YYYY-MM-DD')
         WHEN opAgreementCase.STARTDATE IS NOT NULL
         THEN TO_CHAR(opAgreementCase.STARTDATE, 'YYYY-MM-DD')
     END DDI_STOPPED,
     TO_CHAR(FIRST_VALUE(s.END_DATE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC), 'YYYY-MM-DD')
     subscription_end_date,
     TO_CHAR(ccc.STARTDATE, 'YYYY-MM-DD') debt_case_start,
     ccc.AMOUNT debt_case_amount,
     FIRST_VALUE(prod.NAME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) subscription_type,
     FIRST_VALUE(pg.NAME) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) product_group,
     email.TXTVALUE email,
     mob.TXTVALUE mobil,
     perCreation.txtvalue join_Date,
     CASE
         WHEN FIRST_VALUE(s.END_DATE) OVER (PARTITION BY p.CENTER,p.ID ORDER BY s.END_DATE DESC) IS NOT NULL AND q.QUESTIONS IS NOT NULL THEN
           CAST(COALESCE(
      (xpath('//question[id/text()='||qa.QUESTION_ID ||']/options/option[id/text()='||qa.NUMBER_ANSWER ||']/optionText/text()', xmlparse(document convert_from(q.QUESTIONS,'UTF-8'))))[1]) AS VARCHAR) 
	 END 
      AS leaving_reason,

    RANK() OVER (PARTITION BY qun.center, qun.id ORDER BY qun.LOG_TIME DESC) RN
 FROM
     PERSONS p
 JOIN
     CENTERS c
 ON
     c.id = p.CENTER
 LEFT JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.CENTER
     AND s.OWNER_ID = p.ID
     AND s.STATE IN (2,4,8,3,9)
     AND s.end_date BETWEEN $$fromDate$$ AND $$toDate$$
     AND TO_CHAR(s.START_DATE,'YYYYMM') != TO_CHAR(s.END_DATE,'YYYYMM')
 LEFT JOIN
     PRODUCTS prod
 ON
     prod.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND prod.ID = s.SUBSCRIPTIONTYPE_ID
 LEFT JOIN
     PRODUCT_GROUP pg
 ON
     pg.ID = prod.PRIMARY_PRODUCT_GROUP_ID
     /* Get cash collection cases created this period */
 LEFT JOIN
     CASHCOLLECTIONCASES ccc
 ON
     ccc.PERSONCENTER = p.CENTER
     AND ccc.PERSONID = p.ID
     AND ccc.CLOSED = 0
     AND ccc.MISSINGPAYMENT = 1
     AND ccc.STARTDATE BETWEEN $$fromDate$$ AND $$toDate$$
     /* This will make sure they where clean first day of month */
 LEFT JOIN
     CASHCOLLECTIONCASES msAgreement
 ON
     msAgreement.PERSONCENTER = p.CENTER
     AND msAgreement.PERSONID = p.ID
     AND msAgreement.CLOSED = 0
     AND msAgreement.MISSINGPAYMENT = 0
     AND msAgreement.STARTDATE BETWEEN $$fromDate$$ AND $$toDate$$
 LEFT JOIN
     (
         SELECT
             op_rel.RELATIVECENTER,
             op_rel.RELATIVEID,
             cc.STARTDATE
         FROM
             CASHCOLLECTIONCASES cc
         JOIN
             RELATIVES op_rel
         ON
             op_rel.CENTER = CC.PERSONCENTER
             AND op_rel.ID = CC.PERSONID
             AND op_rel.RTYPE = 12
             AND op_rel.STATUS < 3
         WHERE
             cc.MISSINGPAYMENT = 0
             AND cc.CLOSED = 0 ) opAgreementCase
 ON
     opAgreementCase.RELATIVECENTER = p.CENTER
     AND opAgreementCase.RELATIVEID = p.ID
     AND opAgreementCase.STARTDATE BETWEEN $$fromDate$$ AND $$toDate$$
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     email.PERSONCENTER = p.CENTER
     AND email.PERSONID = p.ID
     AND email.NAME = '_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS mob
 ON
     mob.PERSONCENTER = p.CENTER
     AND mob.PERSONID = p.ID
     AND mob.NAME = '_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS oldId
 ON
     oldId.PERSONCENTER = p.CENTER
     AND oldId.PERSONID = p.ID
     AND oldId.NAME = '_eClub_OldSystemPersonId'
 LEFT JOIN
     CHECKINS ci
 ON
     ci.PERSON_CENTER = p.CENTER
     AND ci.PERSON_ID = p.ID
 LEFT JOIN
     PERSON_EXT_ATTRS perCreation
 ON
     perCreation.PERSONCENTER = p.CENTER
     AND perCreation.PERSONID = p.ID
     AND perCreation.NAME = 'CREATION_DATE'
 LEFT JOIN
     QUESTIONNAIRE_ANSWER QUN
 ON
     QUN.CENTER = P.CENTER
     AND QUN.ID = P.ID
 LEFT JOIN
     QUESTION_ANSWER QA
 ON
     QA.ANSWER_CENTER = QUN.CENTER
     AND QA.ANSWER_ID = QUN.ID
     AND QA.ANSWER_SUBID = QUN.SUBID
 LEFT JOIN
     QUESTIONNAIRE_CAMPAIGNS QC
 ON
     QC.ID = QUN.QUESTIONNAIRE_CAMPAIGN_ID
     AND QC.TYPE = 3
     AND longToDate(qun.LOG_TIME) BETWEEN QC.STARTDATE AND QC.STOPDATE
     AND QC.SCOPE_TYPE = 'A'
 LEFT JOIN
     QUESTIONNAIRES Q
 ON
     q.ID = QC.QUESTIONNAIRE
 WHERE
     p.center IN ($$scope$$)
     /* Person status at run time should be LEAD, ACTIVE or TEMPORARYINACTIVE */
     AND p.STATUS IN (1,3,2)
     /* No companies */
     AND p.SEX != 'C'
     /* No staff members */
     AND p.PERSONTYPE != 2
     /* Exclude product groups */
     AND (
         pg.NAME IS NULL
         OR pg.name NOT IN ( 'Mem Cat: Complimentary',
                            'Legacy Subscriptions (HO only)',
                            'Exclude From Member Count'))
     -- One of the following criteria must be met
     AND (
         msAgreement.CENTER IS NOT NULL
         OR opAgreementCase.STARTDATE IS NOT NULL
         OR ccc.CENTER IS NOT NULL
         OR S.CENTER IS NOT NULL)
     -- Check if rason is sub end date, that there is none starting in future
     AND ( (
             msAgreement.CENTER IS NOT NULL
             OR ccc.CENTER IS NOT NULL
             OR opAgreementCase.STARTDATE IS NOT NULL)
         OR (
             s.CENTER IS NOT NULL
             AND NOT EXISTS
             (
                 /* But make sure we don't have another one that is active/frozen or created  */
                 SELECT
                     1
                 FROM
                     SUBSCRIPTIONS s2
                 WHERE
                     s2.OWNER_CENTER = p.CENTER
                     AND s2.OWNER_ID = p.ID
                     AND s2.STATE IN (2,4,8)
                     AND (
                         s2.end_date IS NULL
                         OR s2.end_date > $$toDate$$ +1)
                     AND (
                         s2.CENTER,s2.ID) NOT IN ((s.CENTER,
                                                   s.ID)))) )
 ) t1
 WHERE RN=1
