-- The extract is extracted from Exerp on 2026-02-08
--  
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
     )
SELECT
    p.EXTERNAL_ID::VARCHAR AS "EXTERNALID",
    p.ZIPCODE AS "POSTALCODE",  
    EMAIL.TXTVALUE AS "EMAIL",
    p.CENTER::VARCHAR AS "GYMID",
    CASE  P.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS "PERSONSTATUS",
    CASE  p.BLACKLISTED  WHEN 0 THEN  'NONE'  WHEN 1 THEN  'BLACKLISTED'  WHEN 2 THEN  'SUSPENDED'  WHEN 3 THEN  'BLOCKED' END            AS "BLACKLISTED",
    TO_CHAR(longtodateTZ(j.creation_time, params.TZFORMAT), params.DATETIMEFORMAT)                                                        AS "BLACKLISTSTARTDATE",
    COALESCE(TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD'), CREATION.TXTVALUE)                                                           AS "MEMBERSINCEDATE",
    CASE AEM.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                       AS "EMAILOPTIN",
    TO_CHAR(longtodateTZ(AEM.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                                     AS "EMAILOPTINDATE",
    CASE ANL.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                       AS "NEWSLETTEROPTIN",
    TO_CHAR(longtodatetz(p.LAST_MODIFIED,params.TZFORMAT), params.DATETIMEFORMAT)                                                         AS "EXERPLASTMODIFIEDDATE",
    dms.FIRSTJOINDATE                                                                                                                     AS "FIRSTJOINEDDATE",
    dms.LASTJOINDATE                                                                                                                      AS "LASTJOINEDDATE",
    TO_CHAR(longtodatetz(last_person_status.LastTime, params.TZFORMAT),'YYYY-MM-DD')                                                      AS "PERSONSTATUSLASTMODIFIEDDATE",
    TO_CHAR(longtodatetz(ANL.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                                     AS "NEWSLETTEROPTINDATE",
    CASE PUSHNOTIFY.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                AS "PUSHNOTIFICATIONOPTIN",
    TO_CHAR(longtodatetz(PUSHNOTIFY.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                              AS "PUSHNOTIFICATIONOPTINDATE",
    CASE SMSMARKET.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                                 AS "SMSMARKETING",
    TO_CHAR(longtodatetz(SMSMARKET.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT)                                               AS "SMSMARKETINGDATE",
    CASE SOCIALMEDIA.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                               AS "SOCIALMEDIAMARKETING",
    TO_CHAR(longtodatetz(SOCIALMEDIA.LAST_EDIT_TIME,params.TZFORMAT), params.DATETIMEFORMAT)                                              AS "SOCIALMEDIAMARKETINGDATE",
    CASE ERASUREREQUEST.TXTVALUE WHEN 'true' THEN 1 ELSE 0 END                                                                            AS "ERASUREREQUEST",
	CASE  ALLOWSURVEY.TXTVALUE  WHEN 'true' THEN  1  ELSE 0 END                                                   AS "ALLOWSURVEY",
    TO_CHAR (longtodatetz (ALLOWSURVEY.LAST_EDIT_TIME, params.TZFORMAT), params.DATETIMEFORMAT) AS "ALLOWSURVEYDATE"
FROM
    personS p
JOIN
    PARAMS
ON
    params.center = p.center    
LEFT JOIN
    JOURNALENTRIES j
ON
    j.PERSON_CENTER = p.CENTER
    AND j.PERSON_ID = p.ID
    AND j.ID = p.SUSPENSION_INTERNAL_NOTE
LEFT JOIN person_EXT_ATTRS CREATION ON CREATION.PERSONCENTER = p.CENTER AND CREATION.PERSONID = p.ID AND CREATION.NAME = 'CREATION_DATE'
LEFT JOIN person_EXT_ATTRS AEM ON AEM.PERSONCENTER = p.CENTER AND AEM.PERSONID = p.ID AND AEM.NAME = '_eClub_AllowedChannelEmail'
LEFT JOIN person_EXT_ATTRS SECGYM ON SECGYM.PERSONCENTER = p.CENTER AND SECGYM.PERSONID = p.ID AND SECGYM.NAME = 'SECONDARY_CENTER'
LEFT JOIN person_EXT_ATTRS MAINGYM ON MAINGYM.PERSONCENTER = p.CENTER AND MAINGYM.PERSONID = p.ID AND MAINGYM.NAME = 'MAIN_CENTER_OVERRIDE'
LEFT JOIN person_EXT_ATTRS ANL ON ANL.PERSONCENTER = p.CENTER AND ANL.PERSONID = p.ID AND ANL.NAME = 'eClubIsAcceptingEmailNewsLetters'
LEFT JOIN person_EXT_ATTRS EMAIL ON EMAIL.PERSONCENTER = p.CENTER AND EMAIL.PERSONID = p.ID AND EMAIL.NAME = '_eClub_Email'
LEFT JOIN person_EXT_ATTRS PUSHNOTIFY ON PUSHNOTIFY.PERSONCENTER = p.CENTER AND PUSHNOTIFY.PERSONID = p.ID AND PUSHNOTIFY.NAME = 'PUSHNOTIFICATIONSMARKETING'
LEFT JOIN person_EXT_ATTRS SMSMARKET ON SMSMARKET.PERSONCENTER = p.CENTER AND SMSMARKET.PERSONID = p.ID AND SMSMARKET.NAME = 'SMSMARKETING'
LEFT JOIN person_EXT_ATTRS SOCIALMEDIA ON SOCIALMEDIA.PERSONCENTER = p.CENTER AND SOCIALMEDIA.PERSONID = p.ID AND SOCIALMEDIA.NAME = 'SOCIALMEDIAMARKETING'
LEFT JOIN person_EXT_ATTRS ERASUREREQUEST ON ERASUREREQUEST.PERSONCENTER = p.CENTER AND ERASUREREQUEST.PERSONID = p.ID AND ERASUREREQUEST.NAME = 'ErasureRequest'
LEFT JOIN PERSON_EXT_ATTRS ALLOWSURVEY ON ALLOWSURVEY.PERSONCENTER = p.CENTER AND ALLOWSURVEY.PERSONID = p.ID AND ALLOWSURVEY.NAME = 'AllowSurvey'

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
            personS p
        ON
            p.center = dms.PERSON_CENTER
            AND p.id = dms.PERSON_ID
        JOIN
            personS cp
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
            cp.id
) dms ON dms.PERSON_CENTER = p.CENTER AND dms.PERSON_ID = p.ID
LEFT JOIN
(
        SELECT
            scl.CENTER,
            scl.ID,
            MAX(scl.ENTRY_START_TIME) AS LastTime
        FROM
            STATE_CHANGE_LOG scl
        WHERE
            scl.ENTRY_TYPE = 1
        GROUP BY
            scl.CENTER,
            scl.ID 
) last_person_status ON last_person_status.ID = p.ID AND last_person_status.CENTER = p.CENTER
WHERE
        p.CENTER IN (:Scope)
        AND p.EXTERNAL_ID IS NOT NULL
        AND p.SEX != 'C'
        AND EMAIL.TXTVALUE IS NOT NULL
UNION ALL
     SELECT 
        NULL AS "EXTERNALID",
        NULL AS "POSTALCODE",
        NULL AS "EMAIL",
        NULL AS "GYMID",
        NULL AS "PERSONSTATUS",
        NULL AS "BLACKLISTED",
        NULL AS "BLACKLISTSTARTDATE",
        NULL AS "MEMBERSINCEDATE",
        NULL AS "EMAILOPTIN",
        NULL AS "EMAILOPTINDATE",
        NULL AS "NEWSLETTEROPTIN",
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
		NULL AS "ALLOWSURVEY",
        NULL AS "ALLOWSURVEYDATE" 