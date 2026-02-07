SELECT
    att.CENTER || 'att' || att.ID AS "ID",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
            OR  p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END                                                        AS "PERSON_ID",
    att.START_TIME                                             AS "START_DATETIME",
    att.STOP_TIME                                              AS "STOP_DATETIME",
    att.BOOKING_RESOURCE_CENTER||'br'||att.BOOKING_RESOURCE_ID AS "RESOURCE_ID",
    att.CENTER                                                 AS "CENTER_ID",
    att.ATTEND_USING_CARD                                      AS "ATTEND_USING_CARD",
    att.LAST_MODIFIED                                          AS "ETS"
FROM
    ATTENDS att
LEFT JOIN
    PERSONS p
ON
    p.center = att.PERSON_CENTER
AND p.id = att.PERSON_ID
