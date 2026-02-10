-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT 
    P.CENTER || 'p' || P.ID                        AS "MEMBERNO",
    to_char(p.CENTER)                              AS "PCENTER",
    to_char(p.ID)                                  AS "PID",	
    to_char(p.EXTERNAL_ID)                         AS "EXTERNALID",
    trim(P.FIRSTNAME)                              AS "FIRSTNAME",
    trim(P.LASTNAME)                               AS "LASTNAME",	
    to_char(p.BIRTHDATE,'YYYY-MM-DD')              AS "BIRTHDATE",
    p.SEX                                          AS "GENDER",
    p.ADDRESS1                                     AS "ADDRESS1",
    p.ADDRESS2                                     AS "ADDRESS2",
    p.COUNTRY                                      AS "COUNTRY",
    P.ZIPCODE                                      AS "POSTALCODE",	
    pea.EMAIL_TXTVALUE                             AS "EMAIL",
    pea.MOBILE_TXTVALUE                            AS "MOBILE",
    pea.HOMEPHONE_TXTVALUE                         AS "PHONE",	
    pea.WORKZIP_TXTVALUE                           AS "WORKPOSTCODE",	
    to_char(p.CENTER)                              AS "GYMID",
    pea.MAINGYM_TXTVALUE                           AS "OVERRIDEGYMID",
    pea.SECGYM_TXTVALUE                            AS "SECONDARYGYMID",	
    e.IDENTITY                                     AS "MEMBERS_PIN",
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS "PERSONTYPE",
    DECODE (P.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED',8, 'ANONYMIZED', 9, 'CONTACT', 'UNKNOWN') AS "PERSONSTATUS",
    DECODE (p.BLACKLISTED, 0, 'NONE', 1, 'BLACKLISTED', 2, 'SUSPENDED', 3, 'BLOCKED') AS "BLACKLISTED",
    TO_CHAR(longtodateTZ(j.creation_time, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS')  AS "BLACKLISTSTARTDATE",
    p.MEMBERDAYS                                   AS "MEMBERDAYS",
    p.ACCUMULATED_MEMBERDAYS                       AS "ACCUMULATEDMEMBERDAYS",
    to_char(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD') AS "LASTACTIVESTARTDATE",
    to_char(p.LAST_ACTIVE_END_DATE,'YYYY-MM-DD')   AS "LASTACTIVEENDDATE",
    NVL(TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD'), pea.CREATION_TXTVALUE) AS "MEMBERSINCEDATE",	
    TO_CHAR(longtodateTZ(pea.APPLOGIN_LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "APPLASTLOGINDATE",	
    DECODE(pea.AEM_TXTVALUE,'true',1,0)            AS "EMAILOPTIN",
    TO_CHAR(longtodateTZ(pea.AEM_LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "EMAILOPTINDATE",
    DECODE(pea.ANL_TXTVALUE,'true',1,0)            AS "NEWSLETTEROPTIN",
    pea.RELATIONAL_TXTVALUE                        AS "TRP_RELATIONAL",
    pea.ATTENDANCE_TXTVALUE                        AS "TRP_ATTENDANCE",
    pea.BUDDYCHKIN_TXTVALUE                        AS                  "MAXBUDDYCHECKINDAYSPERMONTH",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "EXERPLASTMODIFIEDDATE",
    dms.FIRSTJOINDATE                                                                                                                                                                AS "FIRSTJOINEDDATE",
    dms.LASTJOINDATE                                                                                                                                                                AS "LASTJOINEDDATE"
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
LEFT JOIN
    (
        SELECT *
        FROM
        (
            SELECT
                PERSONCENTER,
                PERSONID,
                NAME,
                TXTVALUE,				
                LAST_EDIT_TIME
            FROM
                PUREGYM.PERSON_EXT_ATTRS
            WHERE NAME IN ( '_eClub_HasLoggedInMemberMobileApp', 
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
                            'BUDDYATTENDSPERMONTH' )
        )
        PIVOT
        (
            MAX(LAST_EDIT_TIME) AS LAST_EDIT_TIME,
            MAX(TXTVALUE) AS TXTVALUE 	
            FOR NAME IN ( '_eClub_HasLoggedInMemberMobileApp'    AS APPLOGIN, 
                            'SECONDARY_CENTER'                   AS SECGYM,
                            'MAIN_CENTER_OVERRIDE'               AS MAINGYM,
                            'CREATION_DATE'                      AS CREATION,
                            '_eClub_AllowedChannelEmail'         AS AEM,
                            'eClubIsAcceptingEmailNewsLetters' AS ANL,
                            '_eClub_Email'                       AS EMAIL,
                            '_eClub_PhoneSMS'                    AS MOBILE,
                            '_eClub_PhoneHome'                   AS HOMEPHONE,
                            'WORK_POST_CODE'                     AS WORKZIP,
                            'ATTENDANCE_NPS'                     AS ATTENDANCE,
                            'RELATIONAL_NPS'                     AS RELATIONAL,
                            'BUDDYATTENDSPERMONTH'               AS BUDDYCHKIN)
        )
    ) pea
ON
    pea.personcenter = p.center
    AND pea.personid = p.id
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
                               9)
        GROUP BY
            cp.center,
            cp.id) dms
ON
    dms.PERSON_CENTER = p.center
    AND dms.PERSON_ID = p.id
WHERE
    p.CENTER in ($$scope$$)
    AND p.SEX != 'C'
    AND p.STATUS IN (0,2)