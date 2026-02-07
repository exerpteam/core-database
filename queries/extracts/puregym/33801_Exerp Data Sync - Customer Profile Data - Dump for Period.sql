SELECT
    P.CENTER || 'p' || P.ID                                                                                                                                                         AS "MEMBERNO",
    TO_CHAR(p.CENTER)                                                                                                                                                               AS "PCENTER",
    TO_CHAR(p.ID)                                                                                                                                                                   AS "PID",
    TO_CHAR(p.EXTERNAL_ID)                                                                                                                                                          AS "EXTERNALID",
    trim(P.FIRSTNAME)                                                                                                                                                               AS "FIRSTNAME",
    trim(P.LASTNAME)                                                                                                                                                                AS "LASTNAME",
    TO_CHAR(p.BIRTHDATE,'YYYY-MM-DD')                                                                                                                                               AS "BIRTHDATE",
    p.SEX                                                                                                                                                                           AS "GENDER",
    p.ADDRESS1                                                                                                                                                                      AS "ADDRESS1",
    p.ADDRESS2                                                                                                                                                                      AS "ADDRESS2",
    p.COUNTRY                                                                                                                                                                       AS "COUNTRY",
    P.ZIPCODE                                                                                                                                                                       AS "POSTALCODE",
    EMAIL.TXTVALUE                                                                                                                                                              AS "EMAIL",
    MOBILE.TXTVALUE                                                                                                                                                             AS "MOBILE",
    HOMEPHONE.TXTVALUE                                                                                                                                                          AS "PHONE",
    WORKZIP.TXTVALUE                                                                                                                                                            AS "WORKPOSTCODE",
    TO_CHAR(p.CENTER)                                                                                                                                                               AS "GYMID",
    MAINGYM.TXTVALUE                                                                                                                                                            AS "OVERRIDEGYMID",
    SECGYM.TXTVALUE                                                                                                                                                             AS "SECONDARYGYMID",
    e.IDENTITY                                                                                                                                                                      AS "MEMBERS_PIN",
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS "PERSONTYPE",
    DECODE (P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS "PERSONSTATUS",
    DECODE (p.BLACKLISTED, 0, 'NONE', 1, 'BLACKLISTED', 2, 'SUSPENDED', 3, 'BLOCKED')                                                                                               AS "BLACKLISTED",
    TO_CHAR(longtodateTZ(j.creation_time, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS')                                                                                                AS "BLACKLISTSTARTDATE",
    p.MEMBERDAYS                                                                                                                                                                    AS "MEMBERDAYS",
    p.ACCUMULATED_MEMBERDAYS                                                                                                                                                        AS "ACCUMULATEDMEMBERDAYS",
    TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD')                                                                                                                                  AS "LASTACTIVESTARTDATE",
    TO_CHAR(p.LAST_ACTIVE_END_DATE,'YYYY-MM-DD')                                                                                                                                    AS "LASTACTIVEENDDATE",
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD'), CREATION.TXTVALUE)                                                                                                      AS "MEMBERSINCEDATE",
    TO_CHAR(longtodateTZ(APPLOGIN.LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                     AS "APPLASTLOGINDATE",
    DECODE(AEM.TXTVALUE,'true',1,0)                                                                                                                                             AS "EMAILOPTIN",
    TO_CHAR(longtodateTZ(AEM.LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                          AS "EMAILOPTINDATE",
    DECODE(ANL.TXTVALUE,'true',1,0)                                                                                                                                             AS "NEWSLETTEROPTIN",
    RELATIONAL.TXTVALUE                                                                                                                                                         AS "TRP_RELATIONAL",
    ATTENDANCE.TXTVALUE                                                                                                                                                         AS "TRP_ATTENDANCE",
    BUDDYCHKIN.TXTVALUE                                                                                                                                                         AS "MAXBUDDYCHECKINDAYSPERMONTH",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                                  AS "EXERPLASTMODIFIEDDATE",
    dms.FIRSTJOINDATE                                                                                                                                                               AS "FIRSTJOINEDDATE",
    dms.LASTJOINDATE                                                                                                                                                                AS "LASTJOINEDDATE",
    TO_CHAR(longtodatetz(last_person_status.LastTime,'Europe/London'),'YYYY-MM-DD')                                                                                                 AS "PERSONSTATUSLASTMODIFIEDDATE",
    TO_CHAR(longtodatetz(ANL.LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                           AS "NEWSLETTEROPTINDATE",
    DECODE(PUSHNOTIFY.TXTVALUE,'true',1,0)                                                                                                                                      AS "PUSHNOTIFICATIONOPTIN",
    TO_CHAR(longtodatetz(PUSHNOTIFY.LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                    AS "PUSHNOTIFICATIONOPTINDATE",
    DECODE(SMSMARKET.TXTVALUE,'true',1,0)                                                                                                                                       AS "SMSMARKETING",
    TO_CHAR(longtodatetz(SMSMARKET.LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                     AS "SMSMARKETINGDATE",
    DECODE(SOCIALMEDIA.TXTVALUE,'true',1,0)                                                                                                                                     AS "SOCIALMEDIAMARKETING",
    TO_CHAR(longtodatetz(SOCIALMEDIA.LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                   AS "SOCIALMEDIAMARKETINGDATE",
    DECODE(ERASUREREQUEST.TXTVALUE,'true',1,0)                                                                                                                                  AS "ERASUREREQUEST",
    DECODE(DISABLEDACCESS.TXTVALUE,'true',1,0)                                                                                                                                  AS "DISABLEDACCESS",
    DECODE(PUREGYMATHOME.TXTVALUE,'true',1,0)                                                                                                                                   AS "PUREGYMTOGETHER",
    deduction_day.INDIVIDUAL_DEDUCTION_DAY                                                                                                                                          AS "DEDUCTIONDAY"
FROM 
    PUREGYM.PERSONS p
JOIN
    centers c
ON
    c.id = p.CENTER
JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
LEFT JOIN
    PUREGYM.JOURNALENTRIES j
ON
    j.PERSON_CENTER = p.CENTER
    AND j.PERSON_ID = p.ID
    AND j.id = p.SUSPENSION_INTERNAL_NOTE
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS APPLOGIN ON APPLOGIN.PERSONCENTER = p.CENTER AND APPLOGIN.PERSONID = p.ID AND APPLOGIN.NAME = '_eClub_HasLoggedInMemberMobileApp'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS SECGYM ON SECGYM.PERSONCENTER = p.CENTER AND SECGYM.PERSONID = p.ID AND SECGYM.NAME = 'SECONDARY_CENTER'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS MAINGYM ON MAINGYM.PERSONCENTER = p.CENTER AND MAINGYM.PERSONID = p.ID AND MAINGYM.NAME = 'MAIN_CENTER_OVERRIDE'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS CREATION ON CREATION.PERSONCENTER = p.CENTER AND CREATION.PERSONID = p.ID AND CREATION.NAME = 'CREATION_DATE'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS AEM ON AEM.PERSONCENTER = p.CENTER AND AEM.PERSONID = p.ID AND AEM.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS ANL ON ANL.PERSONCENTER = p.CENTER AND ANL.PERSONID = p.ID AND ANL.NAME = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS EMAIL ON EMAIL.PERSONCENTER = p.CENTER AND EMAIL.PERSONID = p.ID AND EMAIL.NAME = '_eClub_Email'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS MOBILE ON MOBILE.PERSONCENTER = p.CENTER AND MOBILE.PERSONID = p.ID AND MOBILE.NAME = '_eClub_PhoneSMS'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS HOMEPHONE ON HOMEPHONE.PERSONCENTER = p.CENTER AND HOMEPHONE.PERSONID = p.ID AND HOMEPHONE.NAME = '_eClub_PhoneHome'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS WORKZIP ON WORKZIP.PERSONCENTER = p.CENTER AND WORKZIP.PERSONID = p.ID AND WORKZIP.NAME = 'WORK_POST_CODE'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS ATTENDANCE ON ATTENDANCE.PERSONCENTER = p.CENTER AND ATTENDANCE.PERSONID = p.ID AND ATTENDANCE.NAME = 'ATTENDANCE_NPS'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS RELATIONAL ON RELATIONAL.PERSONCENTER = p.CENTER AND RELATIONAL.PERSONID = p.ID AND RELATIONAL.NAME = 'RELATIONAL_NPS'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS BUDDYCHKIN ON BUDDYCHKIN.PERSONCENTER = p.CENTER AND BUDDYCHKIN.PERSONID = p.ID AND BUDDYCHKIN.NAME = 'BUDDYATTENDSPERMONTH'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS PUSHNOTIFY ON PUSHNOTIFY.PERSONCENTER = p.CENTER AND PUSHNOTIFY.PERSONID = p.ID AND PUSHNOTIFY.NAME = 'PUSHNOTIFICATIONSMARKETING'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS SMSMARKET ON SMSMARKET.PERSONCENTER = p.CENTER AND SMSMARKET.PERSONID = p.ID AND SMSMARKET.NAME = 'SMSMARKETING'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS SOCIALMEDIA ON SOCIALMEDIA.PERSONCENTER = p.CENTER AND SOCIALMEDIA.PERSONID = p.ID AND SOCIALMEDIA.NAME = 'SOCIALMEDIAMARKETING'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS ERASUREREQUEST ON ERASUREREQUEST.PERSONCENTER = p.CENTER AND ERASUREREQUEST.PERSONID = p.ID AND ERASUREREQUEST.NAME = 'ErasureRequest'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS DISABLEDACCESS ON DISABLEDACCESS.PERSONCENTER = p.CENTER AND DISABLEDACCESS.PERSONID = p.ID AND DISABLEDACCESS.NAME = 'DISABLED_ACCESS'
LEFT JOIN PUREGYM.PERSON_EXT_ATTRS PUREGYMATHOME ON PUREGYMATHOME.PERSONCENTER = p.CENTER AND PUREGYMATHOME.PERSONID = p.ID AND PUREGYMATHOME.NAME = 'PUREGYMATHOME'
LEFT JOIN
    PUREGYM.ENTITYIDENTIFIERS e
ON
    e.IDMETHOD = 5
    AND e.ENTITYSTATUS = 1
    AND e.REF_CENTER = p.CENTER
    AND e.REF_ID = p.ID
    AND e.REF_TYPE = 1
LEFT JOIN
    (
        SELECT
            cp.center as PERSON_CENTER,
            cp.id as PERSON_ID,
            MAX(dms.CHANGE_DATE) AS LASTJOINDATE,
            MIN(dms.CHANGE_DATE) AS FIRSTJOINDATE
        FROM
            DAILY_MEMBER_STATUS_CHANGES dms
        JOIN
            PERSONS p
        ON
            p.center = dms.PERSON_CENTER
            AND p.id = dms.PERSON_ID
        JOIN
            PERSONS cp
        ON
            cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
            AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
        WHERE
            dms.ENTRY_STOP_TIME IS NULL
            AND dms.MEMBER_NUMBER_DELTA =1
            AND dms.CHANGE IN (0,
                               1,
                               2,
                               3,
                               6,
                               9,
							   10)
        GROUP BY
            cp.center,
            cp.id) dms
ON
    dms.PERSON_CENTER = p.center
    AND dms.PERSON_ID = p.id
LEFT JOIN
(
  SELECT scl.CENTER, scl.id, MAX(scl.ENTRY_START_TIME) AS LastTime
  FROM 
      STATE_CHANGE_LOG scl
  WHERE
      scl.ENTRY_TYPE = 1  
  GROUP BY 
      scl.CENTER, scl.id
) last_person_status
ON
  last_person_status.id = p.id
  AND last_person_status.center = p.center
LEFT JOIN
(   SELECT distinct
		 ar.CUSTOMERCENTER
        , ar.CUSTOMERID
        , pag.INDIVIDUAL_DEDUCTION_DAY 
    FROM ACCOUNT_RECEIVABLES ar
    join PAYMENT_ACCOUNTS pa on pa.center = ar.center and pa.id = ar.id
    join PAYMENT_AGREEMENTS pag on pag.CENTER = pa.ACTIVE_AGR_center and pag.ID = pa.ACTIVE_AGR_id and pag.SUBID = pa.ACTIVE_AGR_SUBID and pag.state=4
) deduction_day
ON
    deduction_day.CUSTOMERID = p.id
    AND deduction_day.CUSTOMERCENTER = p.center
WHERE
    p.CENTER IN ($$scope$$)
    AND p.SEX != 'C'
    AND p.LAST_MODIFIED >= $$fromdate$$
    AND p.LAST_MODIFIED < $$todate$$ + (86400 * 1000)
    AND p.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER AND p.TRANSFERS_CURRENT_PRS_ID = p.ID