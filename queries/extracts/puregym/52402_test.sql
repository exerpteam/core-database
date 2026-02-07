WITH
    params AS materialized
    (
        SELECT
            puregym.datetolongTZ(TO_CHAR(CURRENT_DATE-2, 'YYYY-MM-DD HH24:MI'), 'Europe/London')::
            bigint AS FROMDATE,
            puregym.datetolongTZ(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), 'Europe/London')::
            bigint AS TODATE
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
    t1.EMAIL_TXTVALUE     AS "EMAIL",
    t1.MOBILE_TXTVALUE    AS "MOBILE",
    t1.HOMEPHONE_TXTVALUE AS "PHONE",
    t1.WORKZIP_TXTVALUE   AS "WORKPOSTCODE",
    "GYMID",
    t1.MAINGYM_TXTVALUE AS "OVERRIDEGYMID",
    t1.SECGYM_TXTVALUE  AS "SECONDARYGYMID",
    "MEMBERS_PIN",
    "PERSONTYPE",
    "PERSONSTATUS",
    "BLACKLISTED",
    TO_CHAR(longtodateTZ(t1.creation_time, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS') AS
    "BLACKLISTSTARTDATE",
    "MEMBERDAYS",
    "ACCUMULATEDMEMBERDAYS",
    "LASTACTIVESTARTDATE" ,
    "LASTACTIVEENDDATE",
    COALESCE(TO_CHAR(CAST("LASTACTIVESTARTDATE" AS DATE),'YYYY-MM-DD'), t1.CREATION_TXTVALUE) AS
    "MEMBERSINCEDATE",
    TO_CHAR(longtodateTZ(t1.APPLOGIN_LAST_EDIT_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS') AS
    "APPLASTLOGINDATE",
    CASE t1.AEM_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END                                                                             AS "EMAILOPTIN",
    TO_CHAR(longtodateTZ(t1.AEM_LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS
    "EMAILOPTINDATE",
    CASE t1.ANL_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END                    AS "NEWSLETTEROPTIN",
    t1.RELATIONAL_TXTVALUE AS "TRP_RELATIONAL",
    t1.ATTENDANCE_TXTVALUE AS "TRP_ATTENDANCE",
    t1.BUDDYCHKIN_TXTVALUE AS "MAXBUDDYCHECKINDAYSPERMONTH",
    "EXERPLASTMODIFIEDDATE",
    t1.FIRSTJOINDATE AS "FIRSTJOINEDDATE",
    t1.LASTJOINDATE  AS "LASTJOINEDDATE",
    /*TO_CHAR(longtodatetz(last_person_status.LastTime,'Europe/London'),'YYYY-MM-DD') AS
    "PERSONSTATUSLASTMODIFIEDDATE",*/
    TO_CHAR(longtodatetz(t1.ANL_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS
    "NEWSLETTEROPTINDATE",
    CASE t1.PUSHNOTIFY_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END                                                                  AS "PUSHNOTIFICATIONOPTIN",
    TO_CHAR(longtodatetz(t1.PUSHNOTIFY_LAST_EDIT_TIME,'Europe/London'), 'YYYY-MM-DD HH24:MI:SS') AS
    "PUSHNOTIFICATIONOPTINDATE",
    CASE t1.SMSMARKET_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END                                                                           AS "SMSMARKETING",
    TO_CHAR(longtodatetz(t1.SMSMARKET_LAST_EDIT_TIME,'Europe/London'), 'YYYY-MM-DD HH24:MI:SS') AS
    "SMSMARKETINGDATE",
    CASE t1.SOCIALMEDIA_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "SOCIALMEDIAMARKETING",
    TO_CHAR(longtodatetz(t1.SOCIALMEDIA_LAST_EDIT_TIME,'Europe/London'), 'YYYY-MM-DD HH24:MI:SS')
    AS "SOCIALMEDIAMARKETINGDATE",
    CASE t1.ERASUREREQUEST_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "ERASUREREQUEST",
    CASE t1.DISABLEDACCESS_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "DISABLEDACCESS",
    CASE t1.PUREGYMATHOME_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "PUREGYMTOGETHER",
    "DEDUCTIONDAY",
    CASE t1.ALLOWSURVEY_TXTVALUE
        WHEN 'true'
        THEN 1
        ELSE 0
    END AS "ALLOWSURVEY",
    TO_CHAR (longtodatetz (t1.ALLOWSURVEY_LAST_EDIT_TIME, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS'
    ) AS "ALLOWSURVEYDATE"
FROM
    (
        SELECT distinct
            p.id,
            p.center,
            p.SUSPENSION_INTERNAL_NOTE ,
            P.CENTER || 'p' || P.ID            AS "MEMBERNO",
            (p.CENTER )::VARCHAR               AS "PCENTER",
            (p.ID):: VARCHAR                   AS "PID",
            (p.EXTERNAL_ID )::VARCHAR          AS "EXTERNALID",
            trim (P.FIRSTNAME)                 AS "FIRSTNAME",
            trim (P.LASTNAME)                  AS "LASTNAME",
            TO_CHAR (p.BIRTHDATE,'YYYY-MM-DD') AS "BIRTHDATE",
            p.SEX                              AS "GENDER",
            p.ADDRESS1                         AS "ADDRESS1",
            p.ADDRESS2                         AS "ADDRESS2",
            p.COUNTRY                          AS "COUNTRY",
            P.ZIPCODE                          AS "POSTALCODE",
            (p.CENTER)::VARCHAR                AS "GYMID",
            max(t.IDENTITY)                         AS "MEMBERS_PIN",
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
            t.INDIVIDUAL_DEDUCTION_DAY                                            AS "DEDUCTIONDAY",
            TO_CHAR(longtodatetz(p.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS
                                    "EXERPLASTMODIFIEDDATE",
                                    j.creation_time,
            MAX(dms.CHANGE_DATE) AS LASTJOINDATE,
            MIN(dms.CHANGE_DATE) AS FIRSTJOINDATE ,
            MAX(
                CASE
                    WHEN peat.name = '_eClub_HasLoggedInMemberMobileApp'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS APPLOGIN_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN peat.name = 'SECONDARY_CENTER'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS SECGYM_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'MAIN_CENTER_OVERRIDE'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS MAINGYM_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'CREATION_DATE'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS CREATION_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = '_eClub_AllowedChannelEmail'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS AEM_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN peat.name = '_eClub_AllowedChannelEmail'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS AEM_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'eClubIsAcceptingEmailNewsLetters'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS ANL_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN peat.name = 'eClubIsAcceptingEmailNewsLetters'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS ANL_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = '_eClub_Email'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS EMAIL_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = '_eClub_PhoneSMS'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS MOBILE_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = '_eClub_PhoneHome'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS HOMEPHONE_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'WORK_POST_CODE'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS WORKZIP_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'ATTENDANCE_NPS'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS ATTENDANCE_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'RELATIONAL_NPS'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS RELATIONAL_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'BUDDYATTENDSPERMONTH'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS BUDDYCHKIN_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'PUSHNOTIFICATIONSMARKETING'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS PUSHNOTIFY_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN peat.name = 'PUSHNOTIFICATIONSMARKETING'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS PUSHNOTIFY_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'SMSMARKETING'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS SMSMARKET_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN peat.name = 'SMSMARKETING'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS SMSMARKET_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'SOCIALMEDIAMARKETING'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS SOCIALMEDIA_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN peat.name = 'SOCIALMEDIAMARKETING'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS SOCIALMEDIA_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'ErasureRequest'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS ERASUREREQUEST_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'DISABLED_ACCESS'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS DISABLEDACCESS_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'PUREGYMATHOME'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS PUREGYMATHOME_TXTVALUE,
            MAX(
                CASE
                    WHEN peat.name = 'AllowSurvey'
                    THEN LAST_EDIT_TIME
                    ELSE NULL
                END) AS ALLOWSURVEY_LAST_EDIT_TIME,
            MAX(
                CASE
                    WHEN peat.name = 'AllowSurvey'
                    THEN TXTVALUE
                    ELSE NULL
                END) AS ALLOWSURVEY_TXTVALUE
        FROM
            (
                SELECT
                    pcl.person_center AS center,
                    pcl.person_id     AS id ,
                    NULL::text        AS IDENTITY,
                    NULL::INTEGER     AS INDIVIDUAL_DEDUCTION_DAY
                FROM
                    person_change_logs pcl
                CROSS JOIN
                    params
                WHERE
                    entry_time >= PARAMS.FROMDATE
                AND entry_time < PARAMS.TODATE
                AND pcl.person_center IN ($$scope$$)
                UNION ALL
                SELECT
                    e.REF_CENTER ,
                    e.REF_ID,
                    e.IDENTITY,
                    NULL AS INDIVIDUAL_DEDUCTION_DAY
                FROM
                    params,
                    ENTITYIDENTIFIERS e
                WHERE
                    e.IDMETHOD = 5
                AND e.ENTITYSTATUS = 1
                AND e.REF_TYPE = 1
                AND e.start_time >= PARAMS.FROMDATE
                AND e.start_time < PARAMS.TODATE
                AND e.REF_CENTER IN ($$scope$$)
                UNION ALL
                SELECT
                    ar.CUSTOMERCENTER,
                    ar.CUSTOMERID,
                    NULL AS identity,
                    pag.INDIVIDUAL_DEDUCTION_DAY
                FROM
                    ACCOUNT_RECEIVABLES ar
                CROSS JOIN
                    params
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
                AND pag.INDIVIDUAL_DEDUCTION_DAY IS NOT NULL
                AND pag.last_modified >= PARAMS.FROMDATE
                AND pag.last_modified < PARAMS.TODATE
                AND ar.CUSTOMERCENTER IN ($$scope$$)
                -- option 1 union all 3 and then join to persons to filter such that only transfer
                -- current is
                -- included
                -- option 2 union pcl and e, select from persons where id in cte or last_modified
                -- recent
                -- option 3 join to persons in pcl and e, filter on current transfer, union with
                -- persons with
                -- recent last modified
                UNION ALL
                SELECT
                    center,
                    id ,
                    NULL::text    AS IDENTITY,
                    NULL::INTEGER AS INDIVIDUAL_DEDUCTION_DAY
                FROM
                    persons p
                CROSS JOIN
                    params
                WHERE
                    p.CENTER IN ($$scope$$)
                AND p.SEX != 'C'
                AND p.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
                AND p.TRANSFERS_CURRENT_PRS_ID = p.ID
                AND p.last_modified >= PARAMS.FROMDATE
                AND p.last_modified < PARAMS.TODATE ) t
        JOIN
            persons p
        ON
            p.center = t.center
        AND p.id = t.id
        LEFT JOIN
            DAILY_MEMBER_STATUS_CHANGES dms
        ON
            dms.PERSON_CENTER = p.center
        AND dms.PERSON_ID = p.id
        AND dms.ENTRY_STOP_TIME IS NULL
        AND dms.MEMBER_NUMBER_DELTA =1
        AND dms.CHANGE IN (0,
                           1,
                           2,
                           3,
                           6,
                           9,
                           10)
        LEFT JOIN
            person_ext_attrs peat
        ON
            p.center = peat.PERSONCENTER
        AND p.id = peat.PERSONID
        AND peat.NAME IN ( '_eClub_HasLoggedInMemberMobileApp',
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
        LEFT JOIN
            JOURNALENTRIES j
        ON
            j.PERSON_CENTER = p.CENTER
        AND j.PERSON_ID = p.ID
        AND j.id = p.SUSPENSION_INTERNAL_NOTE
        where 
         p.SEX != 'C'
                AND p.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
                AND p.TRANSFERS_CURRENT_PRS_ID = p.ID
        GROUP BY
            p.id,
            p.center,
            p.SUSPENSION_INTERNAL_NOTE ,
            p.EXTERNAL_ID,
            P.FIRSTNAME,
            P.LASTNAME,
            p.BIRTHDATE,
            p.SEX ,
            p.ADDRESS1 ,
            p.ADDRESS2 ,
            p.COUNTRY ,
            P.ZIPCODE ,
            --t.IDENTITY ,
            p.PERSONTYPE,
            P.STATUS,
            p.BLACKLISTED,
            p.ACCUMULATED_MEMBERDAYS ,
            LAST_ACTIVE_START_DATE,
            LAST_ACTIVE_END_DATE,
            t.INDIVIDUAL_DEDUCTION_DAY ,
            p.LAST_MODIFIED,
            j.creation_time) t1