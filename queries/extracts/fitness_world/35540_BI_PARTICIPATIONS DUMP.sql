-- This is the version from 2026-02-05
--  
SELECT
    p.CENTER || 'par' || p.ID                                  AS "PARTICIPATION_ID",
    p.BOOKING_CENTER || 'bk' || p.BOOKING_ID                      AS "BOOKING_ID",
    p.CENTER                                                      AS "CENTER_ID",
    cp.EXTERNAL_ID                                                AS "PERSON_ID",
    TO_CHAR(longtodate(p.CREATION_TIME), 'YYYY-MM-DD HH24:MI:SS')           AS "CREATION_DATE_TIME",
    p.STATE                                                                       AS "STATE",
    BI_DECODE_FIELD('PARTICIPATIONS','USER_INTERFACE_TYPE',p.USER_INTERFACE_TYPE) AS
                                                                              "USER_INTERFACE_TYPE",
    TO_CHAR(longtodateC(p.SHOWUP_TIME, p.CENTER), 'YYYY-MM-DD HH24:MI:SS')        AS "SHOW_UP_TIME",
    BI_DECODE_FIELD('PARTICIPATIONS','SHOWUP_INTERFACE_TYPE',p.SHOWUP_INTERFACE_TYPE) AS
    "SHOW_UP_INTERFACE_TYPE",
    CASE p.SHOWUP_USING_CARD
        WHEN 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END                                                                      AS "SHOWUP_USING_CARD",
    TO_CHAR(longtodateC(p.CANCELATION_TIME, p.CENTER), 'YYYY-MM-DD HH24:MI:SS')    AS "CANCEL_TIME",
    BI_DECODE_FIELD('PARTICIPATIONS','CANCELATION_INTERFACE_TYPE',p.CANCELATION_INTERFACE_TYPE) AS
                            "CANCEL_INTERFACE_TYPE",
    p.CANCELATION_REASON AS "CANCEL_REASON",
    CASE p.ON_WAITING_LIST
        WHEN 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END             AS "WAS_ON_WAITING_LIST",
    p.LAST_MODIFIED AS "ETS"
FROM
    PARTICIPATIONS p
JOIN
    BOOKINGS b
ON
    p.BOOKING_CENTER = b.CENTER
AND p.BOOKING_ID = b.ID
JOIN
    CENTERS c
ON
    p.CENTER = c.ID
JOIN
    persons per
ON
    per.CENTER = p.PARTICIPANT_CENTER
AND per.ID = p.PARTICIPANT_ID
JOIN
    PERSONS cp
ON
    cp.CENTER = per.CURRENT_PERSON_CENTER
    AND cp.id = per.CURRENT_PERSON_ID
WHERE
    p.CREATION_TIME BETWEEN (($$from_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000 AND ((
            $$to_time$$-to_date('1-1-1970','MM-DD-YYYY')) )*24*3600*1000
