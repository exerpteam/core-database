-- This is the version from 2026-02-05
--  
SELECT
    biview.*
FROM
    (SELECT
    b.CENTER || 'bk' || b.ID                                                 AS "BOOKING_ID",
    b.NAME                                                                   AS "NAME",
    b.CENTER                                                                 AS "CENTER_ID",
    CAST ( b.ACTIVITY AS VARCHAR(255))                                       AS "ACTIVITY_ID",
    cg.NAME                                                                  AS "COLOR",
    TO_CHAR(longtodateC(b.STARTTIME, b.CENTER), 'YYYY-MM-DD HH24:MI:SS')     AS "START_DATE_TIME",
    TO_CHAR(longtodateC(b.STOPTIME, b.CENTER), 'YYYY-MM-DD HH24:MI:SS')      AS "STOP_DATE_TIME",
    TO_CHAR(longtodateC(b.CREATION_TIME, b.CENTER), 'YYYY-MM-DD HH24:MI:SS') AS "CREATION_DATE_TIME",
    b.STATE                                                                  AS "STATE",
    COALESCE (b.CLASS_CAPACITY,0)                                            AS "CLASS_CAPACITY",
    COALESCE (b.WAITING_LIST_CAPACITY,0)                                     AS "WAITING_LIST_CAPACITY",
    CASE
        WHEN b.CANCELATION_TIME IS NOT NULL
        THEN TO_CHAR(longtodateC(b.CANCELATION_TIME, b.CENTER), 'YYYY-MM-DD HH24:MI:SS' )
        ELSE NULL
    END AS "CANCEL_DATE_TIME",
    CASE
        WHEN b.CANCELATION_TIME IS NOT NULL
        THEN B.CANCELLATION_REASON
        ELSE NULL
    END             AS "CANCEL_REASON",
    b.LAST_MODIFIED AS "ETS"
FROM
    BOOKINGS b
JOIN
    CENTERS c
ON
    c.ID = b.CENTER
JOIN
    ACTIVITY a
ON
    a.ID = b.ACTIVITY
LEFT JOIN
    COLOUR_GROUPS cg
ON
    b.COLOUR_GROUP_ID = cg.ID
    AND b.COLOUR_GROUP_ID IS NOT NULL
where b.STARTTIME < 2551089765000 and b.STARTTIME < 2551089765000 ) biview
