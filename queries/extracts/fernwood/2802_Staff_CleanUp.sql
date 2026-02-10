-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    p.center || 'p' || p.id AS PersonId,
    p.external_id,
    (
        CASE p.status
            WHEN 1
            THEN 'ACTIVE'
            WHEN 2
            THEN 'INACTIVE'
            WHEN 3
            THEN 'TEMPORARY INACTIVE'
            WHEN 4
            THEN 'TRANSFERRED'
            WHEN 5
            THEN 'DUPLICATE'
            WHEN 7
            THEN 'DELETED'
            WHEN 8
            THEN 'ANONYMIZED'
            WHEN 9
            THEN 'CONTACT'
            ELSE 'UNKNOWN'
        END) AS PersonStatus,
    p.firstname,
    p.lastname,
    p.birthdate,
    email.txtvalue AS Email,
    sms.txtvalue   AS SMS,
    oldid.txtvalue AS OldId,
    token.txtvalue AS Token,
    (
        CASE
            WHEN oldid.txtvalue LIKE '%-%'
            THEN 'MERGED_MEMBER'
            ELSE 'NORMAL_STAFF'
        END) AS Type,
    (
        CASE
            WHEN sub.center IS NOT NULL
            THEN 'YES'
            ELSE 'NO'
        END) ActiveSubscription,
    (
        CASE
            WHEN clip.center IS NOT NULL
            THEN 'YES'
            ELSE 'NO'
        END) ActiveClipcard
FROM
    persons p
LEFT JOIN
    person_ext_attrs email
ON
    p.center = email.personcenter
AND p.id = email.personid
AND email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs oldid
ON
    p.center = oldid.personcenter
AND p.id = oldid.personid
AND oldid.name = '_eClub_OldSystemPersonId'
LEFT JOIN
    person_ext_attrs token
ON
    p.center = token.personcenter
AND p.id = token.personid
AND token.name = '_eClub_WellnessCloudUserPermanentToken'
LEFT JOIN
    person_ext_attrs sms
ON
    p.center = sms.personcenter
AND p.id = sms.personid
AND sms.name = '_eClub_PhoneSMS'
LEFT JOIN
    (
        SELECT DISTINCT
            p.center,
            p.id
        FROM
            persons p
        JOIN
            subscriptions s
        ON
            p.center = s.owner_center
        AND p.id = s.owner_id
        WHERE
            p.persontype = 2
        AND s.state IN (2,4,8) ) sub
ON
    sub.center = p.center
AND sub.id = p.id
LEFT JOIN
    (
        SELECT DISTINCT
            p.center,
            p.id
        FROM
            persons p
        JOIN
            clipcards c
        ON
            p.center = c.owner_center
        AND p.id = c.owner_id
        WHERE
            p.persontype = 2
        AND c.clips_left > 0
        AND c.finished = false
        AND c.cancelled = false
        AND c.blocked = false ) clip
ON
    clip.center = p.center
AND clip.id = p.id
WHERE
    p.persontype = 2
ORDER BY
    4,5,6