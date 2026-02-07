SELECT
    pm.ID AS "ID",
    CASE
        WHEN (
                p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (   SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END                         AS "PERSON_ID",
    pm.template_id              AS "TEMPLATE_ID",
    pm.template_type            AS "TEMPLATE_TYPE",
    pm.push_target_id           AS "PUSH_TARGET_ID",
    pm.sent_time                AS "SENT_DATETIME",
    pm.response_code            AS "RESPONSE_CODE",
    LEFT(pm.subject,128)        AS "SUBJECT",
    LEFT(pm.error_message, 128) AS "ERROR_MESSAGE",
    pm.mimetype                 AS "MIME_TYPE",
    pm.receiver_center          AS "CENTER_ID",
    pm.sent_time                AS "ETS"
FROM
    PUSH_MESSAGES pm
LEFT JOIN
    persons p
ON
    pm.receiver_center = p.center
AND pm.receiver_id = p.id
