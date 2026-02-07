/*
 * -----------------------------------------------------------------------
 * Exerp Data Sync - Customer Profile Data - Incremental_modified version2
 * -----------------------------------------------------------------------
 * Description: 
 * Extract ID: 2209
 * Source System: 
 * -----------------------------------------------------------------------
 */

WITH
  params AS materialized
     (
         SELECT
             id   AS  center,
            CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')-interval '3' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS FROMDATE,
            CAST(datetolongC(to_char(date_trunc('day',to_timestamp(getcentertime(ID), 'YYYY-MM-DD HH24:MI:SS')+interval '1' day),'YYYY-MM-DD HH24:MI'), ID) AS BIGINT) AS TODATE,
             'YYYY-MM-DD HH24:MI:SS' DATETIMEFORMAT,
             time_zone  AS       TZFORMAT
         FROM 
             centers 
         WHERE ID in ($$scope$$)    
     )
SELECT
    P.CENTER || 'p' || P.ID                                                                                                                                                         AS "MEMBERNO",
    p.CENTER::VARCHAR                                                                                                                                                               AS "PCENTER",
    p.ID::VARCHAR                                                                                                                                                                   AS "PID",
    cp.EXTERNAL_ID::VARCHAR                                                                                                                                                         AS "EXTERNALID",
    trim(P.FIRSTNAME)                                                                                                                                                               AS "FIRSTNAME",
    trim(P.LASTNAME)                                                                                                                                                                AS "LASTNAME",
    TO_CHAR(p.BIRTHDATE,'YYYY-MM-DD')                                                                                                                                               AS "BIRTHDATE",
    p.SEX                                                                                                                                                                           AS "GENDER",
    p.ADDRESS1                                                                                                                                                                      AS "ADDRESS1",
    p.ADDRESS2                                                                                                                                                                      AS "ADDRESS2",
    p.COUNTRY                                                                                                                                                                       AS "COUNTRY",
    P.ZIPCODE                                                                                                                                                                       AS "POSTALCODE",
    EMAIL.TXTVALUE                                                                                                                                                                  AS "EMAIL",
    MOBILE.TXTVALUE                                                                                                                                                                 AS "MOBILE",
    HOMEPHONE.TXTVALUE                                                                                                                                                              AS "PHONE",
    WORKZIP.TXTVALUE                                                                                                                                                                AS "WORKPOSTCODE",
    p.CENTER::VARCHAR                                                                                                                                                               AS "GYMID",
    MAINGYM.TXTVALUE                                                                                                                                                                AS "OVERRIDEGYMID",
    SECGYM.TXTVALUE                                                                                                                                                                 AS "SECONDARYGYMID",
    e.IDENTITY                                                                                                                                                                      AS "MEMBERS_PIN",
    CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN 'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END                         AS "PERSONTYPE",
    CASE  P.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS "PERSONSTATUS",
    CASE  p.BLACKLISTED  WHEN 0 THEN  'NONE'  WHEN 1 THEN  'BLACKLISTED'  WHEN 2 THEN  'SUSPENDED'  WHEN 3 THEN  'BLOCKED' END                                                      AS "BLACKLISTED",
    TO_CHAR(longtodateTZ(j.creation_time, params.TZFORMAT), params.DATETIMEFORMAT)                                                                                                  AS "BLACKLISTSTARTDATE",
    p.MEMBERDAYS                                                                                                                                                                    AS "MEMBERDAYS",
    p.ACCUMULATED_MEMBERDAYS                                                                                                                                                        AS "ACCUMULATEDMEMBERDAYS",
    TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD')                                                                                                                                  AS "LASTACTIVESTARTDATE",
    TO_CHAR(p.LAST_ACTIVE_END_DATE,'YYYY-MM-DD')                                                                                                                                    AS "LASTACTIVEENDDATE",
    COALESCE(TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD'), CREATION.TXTVALUE)                                                                                                     AS "MEMBERSINCEDATE",
    TO_CHAR(longtodateTZ(APPLOGIN.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                                                                          AS "APPLASTLOGINDATE",
    CASE AEM.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                                                                 AS "EMAILOPTIN",
    TO_CHAR(longtodateTZ(AEM.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                                                                               AS "EMAILOPTINDATE",
    CASE ANL.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                                                                 AS "NEWSLETTEROPTIN",
    RELATIONAL.TXTVALUE                                                                                                                                                             AS "TRP_RELATIONAL",
    ATTENDANCE.TXTVALUE                                                                                                                                                             AS "TRP_ATTENDANCE",
    BUDDYCHKIN.TXTVALUE                                                                                                                                                             AS "MAXBUDDYCHECKINDAYSPERMONTH",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED,params.TZFORMAT), params.DATETIMEFORMAT)                                                                                                   AS "EXERPLASTMODIFIEDDATE",
    dms.FIRSTJOINDATE                                                                                                                                                               AS "FIRSTJOINEDDATE",
    dms.LASTJOINDATE                                                                                                                                                                AS "LASTJOINEDDATE",
    TO_CHAR(longtodatetz(last_person_status.LastTime, params.TZFORMAT),'YYYY-MM-DD')                                                                                                AS "PERSONSTATUSLASTMODIFIEDDATE",
    TO_CHAR(longtodatetz(ANL.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                                                                               AS "NEWSLETTEROPTINDATE",
    CASE PUSHNOTIFY.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                                                          AS "PUSHNOTIFICATIONOPTIN",
    TO_CHAR(longtodatetz(PUSHNOTIFY.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                                                                        AS "PUSHNOTIFICATIONOPTINDATE",
    CASE SMSMARKET.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                                                           AS "SMSMARKETING",
    TO_CHAR(longtodatetz(SMSMARKET.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                                                                         AS "SMSMARKETINGDATE",
    CASE SOCIALMEDIA.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                                                         AS "SOCIALMEDIAMARKETING",
    TO_CHAR(longtodatetz(SOCIALMEDIA.LAST_EDIT_TIME,params.TZFORMAT), params.DATETIMEFORMAT)                                                                                        AS "SOCIALMEDIAMARKETINGDATE",
    CASE ERASUREREQUEST.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                                                      AS "ERASUREREQUEST",
    CASE DISABLEDACCESS.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                                                      AS "DISABLEDACCESS",
    CASE PUREGYMATHOME.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                                                       AS "PUREGYMTOGETHER",
    deduction_day.INDIVIDUAL_DEDUCTION_DAY                                                                                                                                          AS "DEDUCTIONDAY",
    CASE  ALLOWSURVEY.TXTVALUE  WHEN 'true' THEN  1  ELSE 0 END                                                   AS "ALLOWSURVEY",
    TO_CHAR (longtodatetz (ALLOWSURVEY.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT) AS "ALLOWSURVEYDATE",
    member_buddy.BUDDY_EXTERNAL_ID AS "BUDDY_EXTERNAL_ID"
FROM 
    PERSONS p
JOIN
    PERSONS cp
ON
    cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
JOIN
    PARAMS
ON
    params.center = p.center
LEFT JOIN
(
    SELECT DISTINCT ON (per.EXTERNAL_ID)
        per.EXTERNAL_ID AS LEAD_EXTERNAL_ID,
        b_per.EXTERNAL_ID AS BUDDY_EXTERNAL_ID
    FROM RELATIVES rel
    INNER JOIN SUBSCRIPTIONS sub
        ON sub.OWNER_CENTER = rel.CENTER
        AND sub.OWNER_ID = rel.ID
    INNER JOIN PRODUCTS prod
        ON  prod.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
        AND prod.ID = sub.SUBSCRIPTIONTYPE_ID
    INNER JOIN PERSONS per
        ON  per.ID = sub.OWNER_ID
        AND per.CENTER = sub.OWNER_CENTER
    INNER JOIN CLIPCARDS b_clip
        ON b_clip.OWNER_CENTER = rel.RELATIVECENTER
        AND b_clip.OWNER_ID = rel.RELATIVEID
        AND b_clip.FINISHED = 0
        AND b_clip.BLOCKED = 0
        AND b_clip.CANCELLED = 0
    INNER JOIN PRODUCTS b_prod
        ON  b_prod.CENTER = b_clip.CENTER
        AND b_prod.ID = b_clip.ID
    INNER JOIN PERSONS b_per
        ON  b_per.ID = b_clip.OWNER_ID
        AND b_per.CENTER = b_clip.OWNER_CENTER
    WHERE rel.center IN (:scope)
    AND rel.RTYPE = 5
    AND rel.STATUS = 1
    AND prod.GLOBALID like '%GREEN'
    AND b_prod.GLOBALID like 'BAF%'
    AND b_prod.BLOCKED = 0
    AND sub.STATE = 2
    ORDER BY per.EXTERNAL_ID, rel.SUBID ASC
) member_buddy
ON  p.EXTERNAL_ID = member_buddy.LEAD_EXTERNAL_ID
LEFT JOIN
    JOURNALENTRIES j
ON
    j.PERSON_CENTER = p.CENTER
    AND j.PERSON_ID = p.ID
    AND j.id = p.SUSPENSION_INTERNAL_NOTE

LEFT JOIN PERSON_EXT_ATTRS APPLOGIN ON APPLOGIN.PERSONCENTER = p.CENTER AND APPLOGIN.PERSONID = p.ID AND APPLOGIN.NAME = '_eClub_HasLoggedInMemberMobileApp'
LEFT JOIN PERSON_EXT_ATTRS SECGYM ON SECGYM.PERSONCENTER = p.CENTER AND SECGYM.PERSONID = p.ID AND SECGYM.NAME = 'SECONDARY_CENTER'
LEFT JOIN PERSON_EXT_ATTRS MAINGYM ON MAINGYM.PERSONCENTER = p.CENTER AND MAINGYM.PERSONID = p.ID AND MAINGYM.NAME = 'MAIN_CENTER_OVERRIDE'
LEFT JOIN PERSON_EXT_ATTRS CREATION ON CREATION.PERSONCENTER = p.CENTER AND CREATION.PERSONID = p.ID AND CREATION.NAME = 'CREATION_DATE'
LEFT JOIN PERSON_EXT_ATTRS AEM ON AEM.PERSONCENTER = p.CENTER AND AEM.PERSONID = p.ID AND AEM.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN PERSON_EXT_ATTRS ANL ON ANL.PERSONCENTER = p.CENTER AND ANL.PERSONID = p.ID AND ANL.NAME = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN PERSON_EXT_ATTRS EMAIL ON EMAIL.PERSONCENTER = p.CENTER AND EMAIL.PERSONID = p.ID AND EMAIL.NAME = '_eClub_Email'
LEFT JOIN PERSON_EXT_ATTRS MOBILE ON MOBILE.PERSONCENTER = p.CENTER AND MOBILE.PERSONID = p.ID AND MOBILE.NAME = '_eClub_PhoneSMS'
LEFT JOIN PERSON_EXT_ATTRS HOMEPHONE ON HOMEPHONE.PERSONCENTER = p.CENTER AND HOMEPHONE.PERSONID = p.ID AND HOMEPHONE.NAME = '_eClub_PhoneHome'
LEFT JOIN PERSON_EXT_ATTRS WORKZIP ON WORKZIP.PERSONCENTER = p.CENTER AND WORKZIP.PERSONID = p.ID AND WORKZIP.NAME = 'WORK_POST_CODE'
LEFT JOIN PERSON_EXT_ATTRS ATTENDANCE ON ATTENDANCE.PERSONCENTER = p.CENTER AND ATTENDANCE.PERSONID = p.ID AND ATTENDANCE.NAME = 'ATTENDANCE_NPS'
LEFT JOIN PERSON_EXT_ATTRS RELATIONAL ON RELATIONAL.PERSONCENTER = p.CENTER AND RELATIONAL.PERSONID = p.ID AND RELATIONAL.NAME = 'RELATIONAL_NPS'
LEFT JOIN PERSON_EXT_ATTRS BUDDYCHKIN ON BUDDYCHKIN.PERSONCENTER = p.CENTER AND BUDDYCHKIN.PERSONID = p.ID AND BUDDYCHKIN.NAME = 'BUDDYATTENDSPERMONTH'
LEFT JOIN PERSON_EXT_ATTRS PUSHNOTIFY ON PUSHNOTIFY.PERSONCENTER = p.CENTER AND PUSHNOTIFY.PERSONID = p.ID AND PUSHNOTIFY.NAME = 'PUSHNOTIFICATIONSMARKETING'
LEFT JOIN PERSON_EXT_ATTRS SMSMARKET ON SMSMARKET.PERSONCENTER = p.CENTER AND SMSMARKET.PERSONID = p.ID AND SMSMARKET.NAME = 'SMSMARKETING'
LEFT JOIN PERSON_EXT_ATTRS SOCIALMEDIA ON SOCIALMEDIA.PERSONCENTER = p.CENTER AND SOCIALMEDIA.PERSONID = p.ID AND SOCIALMEDIA.NAME = 'SOCIALMEDIAMARKETING'
LEFT JOIN PERSON_EXT_ATTRS ERASUREREQUEST ON ERASUREREQUEST.PERSONCENTER = p.CENTER AND ERASUREREQUEST.PERSONID = p.ID AND ERASUREREQUEST.NAME = 'ErasureRequest'
LEFT JOIN PERSON_EXT_ATTRS DISABLEDACCESS ON DISABLEDACCESS.PERSONCENTER = p.CENTER AND DISABLEDACCESS.PERSONID = p.ID AND DISABLEDACCESS.NAME = 'DISABLED_ACCESS'
LEFT JOIN PERSON_EXT_ATTRS PUREGYMATHOME ON PUREGYMATHOME.PERSONCENTER = p.CENTER AND PUREGYMATHOME.PERSONID = p.ID AND PUREGYMATHOME.NAME = 'PUREGYMATHOME'
LEFT JOIN PERSON_EXT_ATTRS ALLOWSURVEY ON ALLOWSURVEY.PERSONCENTER = p.CENTER AND ALLOWSURVEY.PERSONID = p.ID AND ALLOWSURVEY.NAME = 'AllowSurvey'


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

       JOIN
            (
             SELECT
                        pcl.person_center,
                        pcl.person_id,
                        MAX (pcl.entry_time) AS entry_time
                   FROM
                        person_change_logs pcl
               GROUP BY
                        pcl.person_center,
                        pcl.person_id) pcl_time ON pcl_time.person_id = p.id AND pcl_time.person_center = p.center

  LEFT JOIN
            (
    SELECT distinct
                        ar.CUSTOMERCENTER,
                        ar.CUSTOMERID,
                        pag.INDIVIDUAL_DEDUCTION_DAY, 
                        pag.last_modified
                   FROM
                        ACCOUNT_RECEIVABLES ar
                   JOIN
                        PAYMENT_ACCOUNTS pa ON pa.center = ar.center AND pa.id = ar.id
                   JOIN
                        PAYMENT_AGREEMENTS pag  ON pag.CENTER = pa.ACTIVE_AGR_center AND pag.ID = pa.ACTIVE_AGR_id AND pag.SUBID = pa.ACTIVE_AGR_SUBID
                        AND pag.state = 4) deduction_day ON deduction_day.CUSTOMERID = p.id AND deduction_day.CUSTOMERCENTER = p.center
 
      WHERE
             p.SEX != 'C'
--            AND p.TRANSFERS_CURRENT_PRS_CENTER = p.CENTER
--            AND p.TRANSFERS_CURRENT_PRS_ID = p.ID
            and p.external_id is not null

            AND ((
                pcl_time.entry_time >= PARAMS.FROMDATE
                AND pcl_time.entry_time < PARAMS.TODATE)
                
            or
                 (p.last_modified >= PARAMS.FROMDATE
                AND p.last_modified < PARAMS.TODATE)
                
            or
                 (e.start_time >= PARAMS.FROMDATE
                AND e.start_time < PARAMS.TODATE)
                
            or
                 (deduction_day.last_modified >= PARAMS.FROMDATE
                AND deduction_day.last_modified < PARAMS.TODATE)
                
                ) 

UNION ALL
     SELECT 
        NULL AS "MEMBERNO",
        NULL AS "PCENTER",
        NULL AS "PID",
        NULL AS "EXTERNALID",
        NULL AS "FIRSTNAME",
        NULL AS "LASTNAME",
        NULL AS "BIRTHDATE",
        NULL AS "GENDER",
        NULL AS "ADDRESS1",
        NULL AS "ADDRESS2",
        NULL AS "COUNTRY",
        NULL AS "POSTALCODE",
        NULL AS "EMAIL",
        NULL AS "MOBILE",
        NULL AS "PHONE",
        NULL AS "WORKPOSTCODE",
        NULL AS "GYMID",
        NULL AS "OVERRIDEGYMID",
        NULL AS "SECONDARYGYMID",
        NULL AS "MEMBERS_PIN",
        NULL AS "PERSONTYPE",
        NULL AS "PERSONSTATUS",
        NULL AS "BLACKLISTED",
        NULL AS "BLACKLISTSTARTDATE",
        NULL AS "MEMBERDAYS",
        NULL AS "ACCUMULATEDMEMBERDAYS",
        NULL AS "LASTACTIVESTARTDATE",
        NULL AS "LASTACTIVEENDDATE",
        NULL AS "MEMBERSINCEDATE",
        NULL AS "APPLASTLOGINDATE",
        NULL AS "EMAILOPTIN",
        NULL AS "EMAILOPTINDATE",
        NULL AS "NEWSLETTEROPTIN",
        NULL AS "TRP_RELATIONAL",
        NULL AS "TRP_ATTENDANCE",
        NULL AS "MAXBUDDYCHECKINDAYSPERMONTH",
        NULL AS "EXERPLASTMODIFIEDDATE",
        NULL AS "FIRSTJOINEDDATE",
        NULL AS "LASTJOINEDDATE",
        NULL AS "PERSONSTATUSLASTMODIFIEDDATE",
        NULL AS "NEWSLETTEROPTINDATE",
        NULL AS "PUSHNOTIFICATIONOPTIN",
        NULL AS "PUSHNOTIFICATIONOPTINDATE",
        NULL AS "SMSMARKETING",
        NULL AS "SMSMARKETINGDATE",
        NULL AS "SOCIALMEDIAMARKETING",
        NULL AS "SOCIALMEDIAMARKETINGDATE",
        NULL AS "ERASUREREQUEST",
        NULL AS "DISABLEDACCESS",
        NULL AS "PUREGYMTOGETHER",
        NULL AS "DEDUCTIONDAY",
        NULL AS "ALLOWSURVEY",
        NULL AS "ALLOWSURVEYDATE",
        NULL AS "BUDDY_EXTERNAL_ID"