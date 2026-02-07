SELECT
    s.ID                                     AS "ID",
    s.BOOKING_CENTER || 'book' || s.BOOKING_ID AS "BOOKING_ID",
    s.BOOKING_CENTER                         AS "CENTER_ID",
    CASE
        WHEN (per.CENTER != per.TRANSFERS_CURRENT_PRS_CENTER
                OR per.id != per.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = per.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = per.TRANSFERS_CURRENT_PRS_ID)
        ELSE per.EXTERNAL_ID
    END             AS "PERSON_ID",
    s.STATE         AS "STATE",
    s.STARTTIME     AS "START_DATETIME",
    s.STOPTIME      AS "STOP_DATETIME",
    s.SALARY        AS "SALARY",
    CASE
        WHEN (sub_of.CENTER != sub_of.TRANSFERS_CURRENT_PRS_CENTER
                OR sub_of.id != sub_of.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = sub_of.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = sub_of.TRANSFERS_CURRENT_PRS_ID)
        ELSE sub_of.EXTERNAL_ID
    END             AS "SUBSTITUTE_OF_PERSON_ID",
    b.LAST_MODIFIED AS "ETS",
    s.CANCELLATION_TIME AS "CANCEL_DATETIME"
FROM
    STAFF_USAGE s
LEFT JOIN
    BOOKINGS b
ON
    s.BOOKING_CENTER = b.CENTER
    AND s.BOOKING_ID = b.ID
LEFT JOIN
    CENTERS c
ON
    s.BOOKING_CENTER = c.ID
LEFT JOIN
    persons per
ON
    per.CENTER = s.PERSON_CENTER
    AND per.ID = s.PERSON_ID
LEFT JOIN
    persons sub_of
ON
    sub_of.CENTER = s.original_staff_center
    AND sub_of.ID = s.original_staff_id

