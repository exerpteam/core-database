SELECT
    bp.id   AS "ID",
    bp.name AS "NAME",
    CASE
        WHEN bp.program_type_id IS NULL
        THEN 'COURSE'
        ELSE bpt.type
    END AS "TYPE",
    CASE
        WHEN bp.program_type_id IS NULL
        THEN bp.description
        ELSE bpt.description
    END                AS "DESCRIPTION",
    bp.center          AS "CENTER_ID",
    bp.startdate       AS "START_DATE",
    bp.stopdate        AS "END_DATE",
    bp.state           AS "STATE",
    bp.program_type_id AS "BOOKING_PROGRAM_TYPE_ID",
    bp.activity        AS "ACTIVITY_ID",
    bp.semester_id     AS "SEMESTER_ID"
FROM
    booking_programs bp
LEFT JOIN
    booking_program_types bpt
ON
    bpt.id = bp.program_type_id
LEFT JOIN
    activity a
ON
    a.id = bp.activity
WHERE
    bp.program_type_id IS NOT NULL
OR  a.activity_type = 9