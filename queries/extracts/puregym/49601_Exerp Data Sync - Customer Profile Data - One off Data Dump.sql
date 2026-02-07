 SELECT
     p.EXTERNAL_ID::VARCHAR AS "EXTERNALID",
     p.ZIPCODE AS "POSTALCODE",
     pea.EMAIL_TXTVALUE AS "EMAIL",
     p.CENTER::VARCHAR AS "GYMID",
     CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'
                        WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS "PERSONSTATUS",
     CASE  p.BLACKLISTED  WHEN 0 THEN  'NONE'  WHEN 1 THEN  'BLACKLISTED'  WHEN 2 THEN  'SUSPENDED'  WHEN 3 THEN  'BLOCKED' END AS "BLACKLISTED",
     TO_CHAR(longtodateTZ(j.creation_time, 'Europe/London'), 'YYYY-MM-DD HH24:MI:SS') AS "BLACKLISTSTARTDATE",
     COALESCE(TO_CHAR(p.LAST_ACTIVE_START_DATE,'YYYY-MM-DD'), pea.CREATION_TXTVALUE) AS "MEMBERSINCEDATE",
     CASE pea.AEM_TXTVALUE WHEN 'true' THEN 1 ELSE 0 END AS "EMAILOPTIN",
     TO_CHAR(longtodateTZ(pea.AEM_LAST_EDIT_TIME, 'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "EMAILOPTINDATE",
     CASE pea.ANL_TXTVALUE WHEN 'true' THEN 1 ELSE 0 END AS "NEWSLETTEROPTIN",
     TO_CHAR(longtodatetz(p.LAST_MODIFIED,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "EXERPLASTMODIFIEDDATE",
     dms.FIRSTJOINDATE AS "FIRSTJOINEDDATE",
     dms.LASTJOINDATE AS "LASTJOINEDDATE",
     TO_CHAR(longtodatetz(last_person_status.LastTime,'Europe/London'),'YYYY-MM-DD') AS "PERSONSTATUSLASTMODIFIEDDATE",
     TO_CHAR(longtodatetz(pea.ANL_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "NEWSLETTEROPTINDATE",
     CASE pea.PUSHNOTIFY_TXTVALUE WHEN 'true' THEN 1 ELSE 0 END AS "PUSHNOTIFICATIONOPTIN",
     TO_CHAR(longtodatetz(pea.PUSHNOTIFY_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "PUSHNOTIFICATIONOPTINDATE",
     CASE pea.SMSMARKET_TXTVALUE WHEN 'true' THEN 1 ELSE 0 END AS "SMSMARKETING",
     TO_CHAR(longtodatetz(pea.SMSMARKET_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "SMSMARKETINGDATE",
     CASE pea.SOCIALMEDIA_TXTVALUE WHEN 'true' THEN 1 ELSE 0 END AS "SOCIALMEDIAMARKETING",
     TO_CHAR(longtodatetz(pea.SOCIALMEDIA_LAST_EDIT_TIME,'Europe/London'),'YYYY-MM-DD HH24:MI:SS') AS "SOCIALMEDIAMARKETINGDATE",
     CASE pea.ERASUREREQUEST_TXTVALUE WHEN 'true' THEN 1 ELSE 0 END AS "ERASUREREQUEST"
 FROM
     PERSONS p
 LEFT JOIN
     JOURNALENTRIES j
 ON
     j.PERSON_CENTER = p.CENTER
     AND j.PERSON_ID = p.ID
     AND j.ID = p.SUSPENSION_INTERNAL_NOTE
 LEFT JOIN
(   SELECT
        p.CENTER,
        p.ID,
        MAX(
        CASE
            WHEN pea.NAME = 'CREATION_DATE'
            THEN LAST_EDIT_TIME
            ELSE NULL
        END ) AS CREATION_LAST_EDIT_TIME,
        MAX(
        CASE
            WHEN pea.NAME = 'CREATION_DATE'
            THEN TXTVALUE
            ELSE NULL
        END ) AS CREATION_TXTVALUE,
        MAX(
        CASE
            WHEN pea.NAME = '_eClub_AllowedChannelEmail'
            THEN LAST_EDIT_TIME
            ELSE NULL
        END) AS AEM_LAST_EDIT_TIME,
        MAX(
        CASE
            WHEN pea.NAME = '_eClub_AllowedChannelEmail'
            THEN TXTVALUE
            ELSE NULL
        END ) AS AEM_TXTVALUE,
        MAX(
        CASE
            WHEN pea.NAME = 'eClubIsAcceptingEmailNewsLetters'
            THEN LAST_EDIT_TIME
            ELSE NULL
        END ) AS ANL_LAST_EDIT_TIME,
        MAX(
        CASE
            WHEN pea.NAME = 'eClubIsAcceptingEmailNewsLetters'
            THEN TXTVALUE
            ELSE NULL
        END ) AS ANL_TXTVALUE,
        MAX(
        CASE
            WHEN pea.NAME = '_eClub_Email'
            THEN LAST_EDIT_TIME
            ELSE NULL
        END ) AS EMAIL_LAST_EDIT_TIME,
        MAX(
        CASE
            WHEN pea.NAME = '_eClub_Email'
            THEN TXTVALUE
            ELSE NULL
        END ) AS EMAIL_TXTVALUE,
        MAX(
        CASE
            WHEN pea.NAME = 'PUSHNOTIFICATIONSMARKETING'
            THEN LAST_EDIT_TIME
            ELSE NULL
        END ) AS PUSHNOTIFY_LAST_EDIT_TIME,
        MAX(
        CASE
            WHEN pea.NAME = 'PUSHNOTIFICATIONSMARKETING'
            THEN TXTVALUE
            ELSE NULL
        END ) AS PUSHNOTIFY_TXTVALUE,
        MAX(
        CASE
            WHEN pea.NAME = 'SMSMARKETING'
            THEN LAST_EDIT_TIME
            ELSE NULL
        END ) AS SMSMARKET_LAST_EDIT_TIME,
        MAX(
        CASE
            WHEN pea.NAME = 'SMSMARKETING'
            THEN TXTVALUE
            ELSE NULL
        END ) AS SMSMARKET_TXTVALUE,
        MAX(
        CASE
            WHEN pea.NAME = 'SOCIALMEDIAMARKETING'
            THEN LAST_EDIT_TIME
            ELSE NULL
        END ) AS SOCIALMEDIA_LAST_EDIT_TIME,
        MAX(
        CASE
            WHEN pea.NAME = 'SOCIALMEDIAMARKETING'
            THEN TXTVALUE
            ELSE NULL
        END ) AS SOCIALMEDIA_TXTVALUE,
        MAX(
        CASE
            WHEN pea.NAME = 'ErasureRequest'
            THEN LAST_EDIT_TIME
            ELSE NULL
        END ) AS ERASUREREQUEST_LAST_EDIT_TIME,
        MAX(
        CASE
            WHEN pea.NAME = 'ErasureRequest'
            THEN TXTVALUE
            ELSE NULL
        END ) AS ERASUREREQUEST_TXTVALUE
    FROM
        PERSON_EXT_ATTRS pea
    JOIN
        PERSONS p
    ON
        p.center = pea.PERSONCENTER
    AND p.id = pea.PERSONID
    WHERE
        p.EXTERNAL_ID IS NOT NULL
    AND pea.NAME IN ('CREATION_DATE',
                     '_eClub_AllowedChannelEmail',
                     'eClubIsAcceptingEmailNewsLetters',
                     '_eClub_Email',
                     'PUSHNOTIFICATIONSMARKETING',
                     'SMSMARKETING',
                     'SOCIALMEDIAMARKETING',
                     'ErasureRequest' )
    GROUP BY p.CENTER,
        p.ID ) pea
 ON
     pea.CENTER = p.CENTER
     AND pea.ID = p.ID
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
         AND pea.EMAIL_TXTVALUE IS NOT NULL
