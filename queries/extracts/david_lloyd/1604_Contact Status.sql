-- This is the version from 2026-02-05
--  
SELECT
    "ExternalId"
    ,category
    ,blowout_reason
    ,person_type
    ,person_status
    ,can_contact
FROM
    (SELECT
        p.external_id AS "ExternalId"
        ,tc.name      AS category
        , ts.name     AS blowout_reason
        ,CASE p.PERSONTYPE
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
            WHEN 9
            THEN 'CHILD'
            WHEN 10
            THEN 'EXTERNAL_STAFF'
            ELSE 'Undefined'
        END AS person_type
        ,CASE p.STATUS
            WHEN 0
            THEN 'Lead'
            WHEN 1
            THEN 'Active'
            WHEN 2
            THEN 'Inactive'
            WHEN 3
            THEN 'TemporaryInactive'
            WHEN 4
            THEN 'Transferred'
            WHEN 5
            THEN 'Duplicate'
            WHEN 6
            THEN 'Prospect'
            WHEN 7
            THEN 'Deleted'
            WHEN 8
            THEN 'Anonymized'
            WHEN 9
            THEN 'Contact'
            ELSE 'Undefined'
        END AS person_status
        , CASE
            WHEN channelWhatsapp.txtvalue = 'true'
            OR  channelEmail.txtvalue = 'true'
            OR  channelPhone.txtvalue = 'true'
            OR  channelEmail.txtvalue = 'true'
            THEN 'true'
            ELSE 'false'
        END AS can_contact
        ,ROW_NUMBER() over (
                        PARTITION BY
                            p.external_id
                        ORDER BY
                            t.creation_time DESC) AS rnk
    FROM
        PERSONS p
    LEFT JOIN
        TASKS t
    ON
        p.center = t.PERSON_CENTER
    AND p.id = t.PERSON_ID
    LEFT JOIN
        task_categories tc
    ON
        tc.id = t.task_category_id
    LEFT JOIN
        task_steps ts
    ON
        ts.id = t.step_id
    AND ts.name IN ('Blow Out Lapsed'
                    ,'Blow Out')
    LEFT JOIN
        PERSON_EXT_ATTRS channelPhone
    ON
        p.center =channelPhone.PERSONCENTER
    AND p.id =channelPhone.PERSONID
    AND channelPhone.name='_eClub_AllowedChannelPhone'
    LEFT JOIN
        PERSON_EXT_ATTRS channelSMS
    ON
        p.center =channelSMS.PERSONCENTER
    AND p.id =channelSMS.PERSONID
    AND channelSMS.name='_eClub_AllowedChannelSMS'
    LEFT JOIN
        PERSON_EXT_ATTRS channelEmail
    ON
        p.center =channelEmail.PERSONCENTER
    AND p.id =channelEmail.PERSONID
    AND channelEmail.name='_eClub_AllowedChannelEmail'
    LEFT JOIN
        PERSON_EXT_ATTRS channelWhatsapp
    ON
        p.center=channelWhatsapp.PERSONCENTER
    AND p.id=channelWhatsapp.PERSONID
    AND channelWhatsapp.name='WHATSAPP'
    WHERE
        P.EXTERNAL_ID IN ($$EXTERNALD_IDS$$))
WHERE
    rnk = 1