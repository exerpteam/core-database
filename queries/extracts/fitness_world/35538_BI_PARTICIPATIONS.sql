-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT
    p.CENTER || 'par' || p.ID                                                         AS "PARTICIPATION_ID",
    p.BOOKING_CENTER || 'bk' || p.BOOKING_ID                                          AS "BOOKING_ID",
    p.CENTER                                                                          AS "CENTER_ID",
    cp.EXTERNAL_ID                                                                    AS "PERSON_ID",
    TO_CHAR(longtodate(p.CREATION_TIME), 'YYYY-MM-DD HH24:MI:SS')                     AS "CREATION_DATE_TIME",
    p.STATE                                                                           AS "STATE",
    BI_DECODE_FIELD('PARTICIPATIONS','USER_INTERFACE_TYPE',p.USER_INTERFACE_TYPE)     AS "USER_INTERFACE_TYPE",
    TO_CHAR(longtodateC(p.SHOWUP_TIME, p.CENTER), 'YYYY-MM-DD HH24:MI:SS')            AS "SHOW_UP_TIME",
    BI_DECODE_FIELD('PARTICIPATIONS','SHOWUP_INTERFACE_TYPE',p.SHOWUP_INTERFACE_TYPE) AS "SHOW_UP_INTERFACE_TYPE",
    CASE p.SHOWUP_USING_CARD
        WHEN 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END                                                                                         AS "SHOWUP_USING_CARD",
    TO_CHAR(longtodateC(p.CANCELATION_TIME, p.CENTER), 'YYYY-MM-DD HH24:MI:SS')                 AS "CANCEL_TIME",
    BI_DECODE_FIELD('PARTICIPATIONS','CANCELATION_INTERFACE_TYPE',p.CANCELATION_INTERFACE_TYPE) AS "CANCEL_INTERFACE_TYPE",
    p.CANCELATION_REASON                                                                        AS "CANCEL_REASON",
    CASE p.ON_WAITING_LIST
        WHEN 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END             AS "WAS_ON_WAITING_LIST",
    REPLACE(TO_CHAR(p.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    PARAMS, PARTICIPATIONS p
JOIN
    BOOKINGS b
ON
    p.BOOKING_CENTER = b.CENTER
    AND p.BOOKING_ID = b.ID
JOIN
    CENTERS c
ON
    p.CENTER = c.ID
left JOIN
    persons per
ON
    per.CENTER = p.PARTICIPANT_CENTER
    AND per.ID = p.PARTICIPANT_ID
left JOIN
    PERSONS cp
ON
    cp.CENTER = per.CURRENT_PERSON_CENTER
    AND cp.id = per.CURRENT_PERSON_ID
WHERE
    p.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
