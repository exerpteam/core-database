WITH
    params AS materialized
    (
        SELECT
            datetolongTZ(TO_CHAR(TRUNC(CURRENT_DATE)-2, 'YYYY-MM-DD HH24:MI'), 'Europe/London')::bigint AS FROMDATE,
            datetolongTZ(TO_CHAR(TRUNC(CURRENT_DATE+1), 'YYYY-MM-DD HH24:MI'), 'Europe/London')::bigint AS TODATE
    )
SELECT
    "MEMBERNO",
    "PCENTER",
    "PID",
    "EXTERNALID",
    "FIRSTNAME",
    "LASTNAME",
    "BIRTHDATE",
    "GENDER",
    "ADDRESS1",
    "ADDRESS2",
    "COUNTRY",
    "POSTALCODE",
    pea.EMAIL_TXTVALUE                                                                   AS "EMAIL",
    pea.MOBILE_TXTVALUE                                                                 AS "MOBILE",
    pea.HOMEPHONE_TXTVALUE                                                               AS "PHONE",
    pea.WORKZIP_TXTVALUE                                                          AS "WORKPOSTCODE",
    "GYMID",
    pea.MAINGYM_TXTVALUE                                                         AS "OVERRIDEGYMID",
    pea.SECGYM_TXTVALUE                                                         AS "SECONDARYGYMID",
    "MEMBERS_PIN",
    "PERSONTYPE",
    "PERSONSTATUS",
    "BLACKLISTED",
    TO_CHAR(longtodateTZ(j.creation_time, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS') AS
    "BLACKLISTSTARTDATE",
    "MEMBERDAYS",
    "ACCUMULATEDMEMBERDAYS",
    "LASTACTIVESTARTDATE" ,
    "LASTACTIVEENDDATE",
    COALESCE(TO_CHAR(CAST("LASTACTIVESTARTDATE" AS DATE),'YYYY-MM-DD'), pea.CREATION_TXTVALUE) AS
    "MEMBERSINCEDATE",
    TO_CHAR(longtodateTZ(pea.APPLOGIN_LAST_EDIT_TIME, 'Europe/London'),
    'YYYY-MM-DD HH24:MI:SS') AS "APPLASTLOGINDATE",
    CASE pea.AEM_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END                                                                 AS "EMAILOPTIN",
    TO_CHAR(longtodateTZ(pea.AEM_LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS
    "EMAILOPTINDATE",
    CASE pea.ANL_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END                                                    AS "NEWSLETTEROPTIN",
    pea.RELATIONAL_TXTVALUE                                         AS "TRP_RELATIONAL",
    pea.ATTENDANCE_TXTVALUE                                         AS "TRP_ATTENDANCE",
    pea.BUDDYCHKIN_TXTVALUE                            AS "MAXBUDDYCHECKINDAYSPERMONTH",
    "EXERPLASTMODIFIEDDATE",
    dms.FIRSTJOINDATE AS "FIRSTJOINEDDATE",
    dms.LASTJOINDATE  AS "LASTJOINEDDATE",
    TO_CHAR(longtodatetz(last_person_status.LastTime,'Europe/London'),'YYYY-MM-DD') AS
                         "PERSONSTATUSLASTMODIFIEDDATE",
    TO_CHAR(longtodatetz(pea.ANL_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS
    "NEWSLETTEROPTINDATE",
      CASE pea.PUSHNOTIFY_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "PUSHNOTIFICATIONOPTIN",
    TO_CHAR(longtodatetz(pea.PUSHNOTIFY_LAST_EDIT_TIME,'Europe/London'),
    'YYYY-MM-DD HH24:MI:SS') AS "PUSHNOTIFICATIONOPTINDATE",
    CASE pea.SMSMARKET_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "SMSMARKETING",
    TO_CHAR(longtodatetz(pea.SMSMARKET_LAST_EDIT_TIME,'Europe/London'),
    'YYYY-MM-DD HH24:MI:SS') AS "SMSMARKETINGDATE",
    CASE pea.SOCIALMEDIA_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "SOCIALMEDIAMARKETING",
    TO_CHAR(longtodatetz(pea.SOCIALMEDIA_LAST_EDIT_TIME,'Europe/London'),
    'YYYY-MM-DD HH24:MI:SS') AS "SOCIALMEDIAMARKETINGDATE",
    CASE pea.ERASUREREQUEST_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "ERASUREREQUEST",
    CASE pea.DISABLEDACCESS_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "DISABLEDACCESS",
    CASE pea.PUREGYMATHOME_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "PUREGYMTOGETHER",
      "DEDUCTIONDAY",
    CASE pea.ALLOWSURVEY_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "ALLOWSURVEY",
    TO_CHAR (longtodatetz (pea.ALLOWSURVEY_LAST_EDIT_TIME, 'Europe/London'),
    'YYYY-MM-DD HH24:MI:SS')                                                  AS "ALLOWSURVEYDATE" 
   
FROM
    (
        SELECT
            p.id,
            p.center,
            p.SUSPENSION_INTERNAL_NOTE ,
            P.CENTER || 'p' || P.ID           AS "MEMBERNO",
            (p.CENTER)::VARCHAR               AS "PCENTER",
            (p.ID)::VARCHAR                   AS "PID",
            (p.EXTERNAL_ID)::VARCHAR          AS "EXTERNALID",
            trim(P.FIRSTNAME)                 AS "FIRSTNAME",
            trim(P.LASTNAME)                  AS "LASTNAME",
            TO_CHAR(p.BIRTHDATE,'YYYY-MM-DD') AS "BIRTHDATE",
            p.SEX                             AS "GENDER",
            p.ADDRESS1                        AS "ADDRESS1",
            p.ADDRESS2                        AS "ADDRESS2",
            p.COUNTRY                         AS "COUNTRY",
            P.ZIPCODE                         AS "POSTALCODE",
            (p.CENTER)::VARCHAR               AS "GYMID",
            e.IDENTITY                        AS "MEMBERS_PIN",
            CASE p.PERSONTYPE
                WHEN 0
                THEN 'PRIVATE'
                WHEN 1
                THEN 'STUDENT'
                WHEN 2
                THEN 'STAFF'
                WHEN 3
                THEN 'FRIEND'
                WHEN 4
                THEN 'CORPORATE'
                WHEN 5
                THEN 'ONEMANCORPORATE'
                WHEN 6
                THEN 'FAMILY'
                WHEN 7
                THEN 'SENIOR'
                WHEN 8
                THEN 'GUEST'
                ELSE 'UNKNOWN'
            END AS "PERSONTYPE",
            CASE P.STATUS
                WHEN 0
                THEN 'LEAD'
                WHEN 1
                THEN 'ACTIVE'
                WHEN 2
                THEN 'INACTIVE'
                WHEN 3
                THEN 'TEMPORARYINACTIVE'
                WHEN 4
                THEN 'TRANSFERED'
                WHEN 5
                THEN 'DUPLICATE'
                WHEN 6
                THEN 'PROSPECT'
                WHEN 7
                THEN 'DELETED'
                WHEN 8
                THEN 'ANONYMIZED'
                WHEN 9
                THEN 'CONTACT'
                ELSE 'UNKNOWN'
            END AS "PERSONSTATUS",
            CASE p.BLACKLISTED
                WHEN 0
                THEN 'NONE'
                WHEN 1
                THEN 'BLACKLISTED'
                WHEN 2
                THEN 'SUSPENDED'
                WHEN 3
                THEN 'BLOCKED'
            END                                            AS "BLACKLISTED",
            p.MEMBERDAYS                                   AS "MEMBERDAYS",
            p.ACCUMULATED_MEMBERDAYS                       AS "ACCUMULATEDMEMBERDAYS",
            TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD')                 AS "LASTACTIVESTARTDATE",
            TO_CHAR(p.LAST_ACTIVE_END_DATE,'YYYY-MM-DD')                     AS "LASTACTIVEENDDATE",
            deduction_day.INDIVIDUAL_DEDUCTION_DAY                                AS "DEDUCTIONDAY",
            TO_CHAR(longtodatetz(p.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS
            "EXERPLASTMODIFIEDDATE"
        FROM
            persons p
        CROSS JOIN
            PARAMS
        LEFT JOIN
            (
                SELECT
                    pcl.person_center,
                    pcl.person_id,
                    MAX (pcl.entry_time) AS entry_time
                FROM
                    person_change_logs pcl
                CROSS JOIN
                    params
                WHERE
                    entry_time >= PARAMS.FROMDATE
                AND entry_time < PARAMS.TODATE
                GROUP BY
                    pcl.person_center,
                    pcl.person_id) pcl_time
        ON
            pcl_time.person_id = p.id
        AND pcl_time.person_center = p.center
        LEFT JOIN
            ENTITYIDENTIFIERS e
        ON
            e.IDMETHOD = 5
        AND e.ENTITYSTATUS = 1
        AND e.REF_CENTER = p.CENTER
        AND e.REF_ID = p.ID
        AND e.REF_TYPE = 1
        LEFT JOIN
            (
                SELECT
                    ar.CUSTOMERCENTER,
                    ar.CUSTOMERID,
                    pag.INDIVIDUAL_DEDUCTION_DAY,
                    pag.last_modified
                FROM
                    ACCOUNT_RECEIVABLES ar
                JOIN
                    PAYMENT_ACCOUNTS pa
                ON
                    pa.center = ar.center
                AND pa.id = ar.id
                AND ar.ar_type=4
                JOIN
                    PAYMENT_AGREEMENTS pag
                ON
                    pag.CENTER = pa.ACTIVE_AGR_center
                AND pag.ID = pa.ACTIVE_AGR_id
                AND pag.SUBID = pa.ACTIVE_AGR_SUBID
                AND pag.state = 4
                AND pag.INDIVIDUAL_DEDUCTION_DAY IS NOT NULL) deduction_day
        ON
            deduction_day.CUSTOMERID = p.id
        AND deduction_day.CUSTOMERCENTER = p.center
        WHERE
            p.CENTER IN (:scope)
        AND p.SEX != 'C'
        AND p.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
        AND p.TRANSFERS_CURRENT_PRS_ID = p.ID
        AND ( (
                    pcl_time.entry_time >= PARAMS.FROMDATE
                AND pcl_time.entry_time < PARAMS.TODATE )
            OR  (
                    p.last_modified >= PARAMS.FROMDATE
                AND p.last_modified < PARAMS.TODATE )
            OR  (
                    e.start_time >= PARAMS.FROMDATE
                AND e.start_time < PARAMS.TODATE )
            OR  (
                    deduction_day.last_modified >= PARAMS.FROMDATE
                AND deduction_day.last_modified < PARAMS.TODATE ) ) ) selection
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
    last_person_status.id = selection.id
AND last_person_status.center = selection.center
LEFT JOIN
    (
        SELECT
            p.TRANSFERS_CURRENT_PRS_ID     AS PERSON_ID,
            p.TRANSFERS_CURRENT_PRS_CENTER AS PERSON_CENTER,
            MAX(dms.CHANGE_DATE)           AS LASTJOINDATE,
            MIN(dms.CHANGE_DATE)           AS FIRSTJOINDATE
        FROM
            DAILY_MEMBER_STATUS_CHANGES dms
        JOIN
            persons p
        ON
            p.center = dms.PERSON_CENTER
        AND p.id = dms.PERSON_ID
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
            p.TRANSFERS_CURRENT_PRS_ID,
            p.TRANSFERS_CURRENT_PRS_CENTER) dms
ON
    dms.PERSON_CENTER = selection.center
AND dms.PERSON_ID = selection.id
LEFT JOIN
    (
        SELECT
            TRANSFERS_CURRENT_PRS_CENTER,
            TRANSFERS_CURRENT_PRS_ID,
            MAX(
                CASE
                    WHEN name = '_eClub_HasLoggedInMemberMobileApp'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS APPLOGIN_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN name = 'SECONDARY_CENTER'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS SECGYM_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'MAIN_CENTER_OVERRIDE'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS MAINGYM_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'CREATION_DATE'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS CREATION_TXTVALUE,
            MAX(
                CASE
                    WHEN name = '_eClub_AllowedChannelEmail'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS AEM_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN name = '_eClub_AllowedChannelEmail'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS AEM_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'eClubIsAcceptingEmailNewsLetters'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS ANL_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN name = 'eClubIsAcceptingEmailNewsLetters'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS ANL_TXTVALUE,
            MAX(
                CASE
                    WHEN name = '_eClub_Email'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS EMAIL_TXTVALUE,
            MAX(
                CASE
                    WHEN name = '_eClub_PhoneSMS'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS MOBILE_TXTVALUE,
            MAX(
                CASE
                    WHEN name = '_eClub_PhoneHome'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS HOMEPHONE_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'WORK_POST_CODE'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS WORKZIP_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'ATTENDANCE_NPS'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS ATTENDANCE_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'RELATIONAL_NPS'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS RELATIONAL_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'BUDDYATTENDSPERMONTH'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS BUDDYCHKIN_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'PUSHNOTIFICATIONSMARKETING'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS PUSHNOTIFY_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN name = 'PUSHNOTIFICATIONSMARKETING'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS PUSHNOTIFY_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'SMSMARKETING'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS SMSMARKET_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN name = 'SMSMARKETING'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS SMSMARKET_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'SOCIALMEDIAMARKETING'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS SOCIALMEDIA_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN name = 'SOCIALMEDIAMARKETING'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS SOCIALMEDIA_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'ErasureRequest'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS ERASUREREQUEST_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'DISABLED_ACCESS'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS DISABLEDACCESS_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'PUREGYMATHOME'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS PUREGYMATHOME_TXTVALUE,
            MAX(
                CASE
                    WHEN name = 'AllowSurvey'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS ALLOWSURVEY_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN name = 'AllowSurvey'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS ALLOWSURVEY_TXTVALUE
        FROM
            person_ext_attrs peat
        JOIN
            persons p
        ON
            p.center = peat.PERSONCENTER
        AND p.id = peat.PERSONID
        WHERE
            peat.NAME IN ( '_eClub_HasLoggedInMemberMobileApp',
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
                          'ErasureRequest',
                          'DISABLED_ACCESS',
                          'PUREGYMATHOME',
                          'AllowSurvey' )
        GROUP BY
            p.TRANSFERS_CURRENT_PRS_CENTER,
            p.TRANSFERS_CURRENT_PRS_ID ) pea
ON
    pea.TRANSFERS_CURRENT_PRS_CENTER = selection.CENTER
AND pea.TRANSFERS_CURRENT_PRS_ID = selection.id
LEFT JOIN
    JOURNALENTRIES j 
ON
    j.PERSON_CENTER = selection.CENTER
AND j.PERSON_ID = selection.ID
AND j.id = selection.SUSPENSION_INTERNAL_NOTE 