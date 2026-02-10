-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    P.CENTER || 'p' || P.ID                                                                                                                                                         AS "MEMBERNO",
    TO_CHAR(p.CENTER)                                                                                                                                                               AS "PCENTER",
    TO_CHAR(p.ID)                                                                                                                                                                   AS "PID",
    TO_CHAR(cp.EXTERNAL_ID)                                                                                                                                                         AS "EXTERNALID",
    trim(P.FIRSTNAME)                                                                                                                                                               AS "FIRSTNAME",
    trim(P.LASTNAME)                                                                                                                                                                AS "LASTNAME",
    TO_CHAR(p.BIRTHDATE,'YYYY-MM-DD')                                                                                                                                               AS "BIRTHDATE",
    p.SEX                                                                                                                                                                           AS "GENDER",
    p.ADDRESS1                                                                                                                                                                      AS "ADDRESS1",
    p.ADDRESS2                                                                                                                                                                      AS "ADDRESS2",
    p.COUNTRY                                                                                                                                                                       AS "COUNTRY",
    P.ZIPCODE                                                                                                                                                                       AS "POSTALCODE",
    pea.EMAIL_TXTVALUE                                                                                                                                                              AS "EMAIL",
    pea.MOBILE_TXTVALUE                                                                                                                                                             AS "MOBILE",
    pea.HOMEPHONE_TXTVALUE                                                                                                                                                          AS "PHONE",
    pea.WORKZIP_TXTVALUE                                                                                                                                                            AS "WORKPOSTCODE",
    TO_CHAR(p.CENTER)                                                                                                                                                               AS "GYMID",
    pea.MAINGYM_TXTVALUE                                                                                                                                                            AS "OVERRIDEGYMID",
    pea.SECGYM_TXTVALUE                                                                                                                                                             AS "SECONDARYGYMID",
    e.IDENTITY                                                                                                                                                                      AS "MEMBERS_PIN",
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN')                         AS "PERSONTYPE",
    DECODE (P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS "PERSONSTATUS",
    DECODE (p.BLACKLISTED, 0, 'NONE', 1, 'BLACKLISTED', 2, 'SUSPENDED', 3, 'BLOCKED')                                                                                               AS "BLACKLISTED",
    TO_CHAR(longtodateTZ(j.creation_time, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS')                                                                                                AS "BLACKLISTSTARTDATE",
    p.MEMBERDAYS                                                                                                                                                                    AS "MEMBERDAYS",
    p.ACCUMULATED_MEMBERDAYS                                                                                                                                                        AS "ACCUMULATEDMEMBERDAYS",
    TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD')                                                                                                                                  AS "LASTACTIVESTARTDATE",
    TO_CHAR(p.LAST_ACTIVE_END_DATE,'YYYY-MM-DD')                                                                                                                                    AS "LASTACTIVEENDDATE",
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD'), pea.CREATION_TXTVALUE)                                                                                                      AS "MEMBERSINCEDATE",
    TO_CHAR(longtodateTZ(pea.APPLOGIN_LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                     AS "APPLASTLOGINDATE",
    DECODE(pea.AEM_TXTVALUE,'true',1,0)                                                                                                                                             AS "EMAILOPTIN",
    TO_CHAR(longtodateTZ(pea.AEM_LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                          AS "EMAILOPTINDATE",
    DECODE(pea.ANL_TXTVALUE,'true',1,0)                                                                                                                                             AS "NEWSLETTEROPTIN",
    pea.RELATIONAL_TXTVALUE                                                                                                                                                         AS "TRP_RELATIONAL",
    pea.ATTENDANCE_TXTVALUE                                                                                                                                                         AS "TRP_ATTENDANCE",
    pea.BUDDYCHKIN_TXTVALUE                                                                                                                                                         AS "MAXBUDDYCHECKINDAYSPERMONTH",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                                  AS "EXERPLASTMODIFIEDDATE",
    dms.FIRSTJOINDATE                                                                                                                                                               AS "FIRSTJOINEDDATE",
    dms.LASTJOINDATE                                                                                                                                                                AS "LASTJOINEDDATE",
    TO_CHAR(longtodatetz(last_person_status.LastTime,'Europe/London'),'YYYY-MM-DD')                                                                                                 AS "PERSONSTATUSLASTMODIFIEDDATE",
    TO_CHAR(longtodatetz(pea.ANL_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                           AS "NEWSLETTEROPTINDATE",
    DECODE(pea.PUSHNOTIFY_TXTVALUE,'true',1,0)                                                                                                                                      AS "PUSHNOTIFICATIONOPTIN",
    TO_CHAR(longtodatetz(pea.PUSHNOTIFY_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                    AS "PUSHNOTIFICATIONOPTINDATE",
    DECODE(pea.SMSMARKET_TXTVALUE,'true',1,0)                                                                                                                                       AS "SMSMARKETING",
    TO_CHAR(longtodatetz(pea.SMSMARKET_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                     AS "SMSMARKETINGDATE",
    DECODE(pea.SOCIALMEDIA_TXTVALUE,'true',1,0)                                                                                                                                     AS "SOCIALMEDIAMARKETING",
    TO_CHAR(longtodatetz(pea.SOCIALMEDIA_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS')                                                                                   AS "SOCIALMEDIAMARKETINGDATE",
	DECODE(pea.ERASUREREQUEST_TXTVALUE,'true',1,0)                                                                                                                                  AS "ERASUREREQUEST"
FROM
    PUREGYM.PERSONS p
JOIN
    centers c
ON
    c.id = p.CENTER
LEFT JOIN
    PUREGYM.JOURNALENTRIES j
ON
    j.PERSON_CENTER = p.CENTER
    AND j.PERSON_ID = p.ID
    AND j.id = p.SUSPENSION_INTERNAL_NOTE
JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
LEFT JOIN
    (
        SELECT
            *
        FROM
            (
                SELECT
                    p.TRANSFERS_CURRENT_PRS_CENTER,
                    p.TRANSFERS_CURRENT_PRS_ID,
                    pea.NAME,
                    pea.TXTVALUE,
                    pea.LAST_EDIT_TIME
                FROM
                    PUREGYM.PERSON_EXT_ATTRS pea
                JOIN
                    PERSONS p
                ON
                    p.center = pea.PERSONCENTER
                    AND p.id = pea.PERSONID
                WHERE
                    pea.NAME IN ( '_eClub_HasLoggedInMemberMobileApp',
                                 'SECONDARY_CENTER',
                                 'MAIN_CENTER_OVERRIDE',
                                 'CREATION_DATE',
                                 '_eClub_AllowedChannelEmail',
                                 'eClubIsAcceptingEmailNewsLetters',
                                 '_eClub_Email',
                                 '_eClub_PhoneSMS',
                                 '_eClub_PhoneHome',
                                 'WORK_POST_CODE',
                                 'ATTENDANCE_NPS',
                                 'RELATIONAL_NPS',
                                 'BUDDYATTENDSPERMONTH',
                                 'PUSHNOTIFICATIONSMARKETING',
                                 'SMSMARKETING',
                                 'SOCIALMEDIAMARKETING',
                                 'ErasureRequest' ) ) PIVOT ( MAX(LAST_EDIT_TIME) AS LAST_EDIT_TIME, MAX(TXTVALUE) AS TXTVALUE FOR NAME IN ( '_eClub_HasLoggedInMemberMobileApp' AS APPLOGIN,
                                                                                                                                                  'SECONDARY_CENTER'                 AS SECGYM,
                                                                                                                                                  'MAIN_CENTER_OVERRIDE'             AS MAINGYM,
                                                                                                                                                  'CREATION_DATE'                    AS CREATION,
                                                                                                                                                  '_eClub_AllowedChannelEmail'       AS AEM,
                                                                                                                                                  'eClubIsAcceptingEmailNewsLetters' AS ANL,
                                                                                                                                                  '_eClub_Email'                     AS EMAIL,
                                                                                                                                                  '_eClub_PhoneSMS'                  AS MOBILE,
                                                                                                                                                  '_eClub_PhoneHome'                 AS HOMEPHONE,
                                                                                                                                                  'WORK_POST_CODE'                   AS WORKZIP,
                                                                                                                                                  'ATTENDANCE_NPS'                   AS ATTENDANCE,
                                                                                                                                                  'RELATIONAL_NPS'                   AS RELATIONAL,
                                                                                                                                                  'BUDDYATTENDSPERMONTH'             AS BUDDYCHKIN,
                                                                                                                                                  'PUSHNOTIFICATIONSMARKETING'       AS PUSHNOTIFY,
                                                                                                                                                  'SMSMARKETING'                     AS SMSMARKET,
                                                                                                                                                  'SOCIALMEDIAMARKETING'             AS SOCIALMEDIA,
																																				  'ErasureRequest'                   AS ERASUREREQUEST) ) ) pea
ON
    pea.TRANSFERS_CURRENT_PRS_CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
    AND pea.TRANSFERS_CURRENT_PRS_ID = p.TRANSFERS_CURRENT_PRS_ID
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
            cp.center            AS PERSON_CENTER,
            cp.id                AS PERSON_ID,
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
                               9,10)
        GROUP BY
            cp.center,
            cp.id) dms
ON
    dms.PERSON_CENTER = p.center
    AND dms.PERSON_ID = p.id
LEFT JOIN
    (
        SELECT
            scl.CENTER,
            scl.id,
            MAX(scl.ENTRY_START_TIME) AS LastTime
        FROM
            STATE_CHANGE_LOG scl
        WHERE
            scl.ENTRY_TYPE = 1
        GROUP BY
            scl.CENTER,
            scl.id ) last_person_status
ON
    last_person_status.id = p.id
    AND last_person_status.center = p.center
WHERE
    p.CENTER IN ($$scope$$)
    AND p.SEX != 'C'
    AND p.STATUS = 2
	AND p.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER AND p.TRANSFERS_CURRENT_PRS_ID = p.ID 
	AND p.LAST_ACTIVE_END_DATE >= $$fromdate$$