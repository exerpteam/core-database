-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize  */
            c.id AS CENTER_ID,
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolongtz(TO_CHAR(CURRENT_DATE- $$offset$$ , 'YYYY-MM-DD HH24:MI'),
                    c.time_zone)
            END                                                                         AS FROM_DATE,
            datetolongtz(TO_CHAR(CURRENT_DATE+1, 'YYYY-MM-DD HH24:MI'), c.time_zone)    AS TO_DATE
        FROM
            centers c
        WHERE
            c.id IN ($$scope$$)
    )
SELECT
    per.EXTERNAL_ID                                                                     AS "PERSON_ID",
    p.CENTER || 'pa' || p.ID                                                            AS "PARTICIPATIONS.PARTICIPATION_ID",
    p.BOOKING_CENTER || 'book' || p.BOOKING_ID                                          AS "PARTICIPATIONS.BOOKING_ID",
    b.NAME                                                                              AS "PARTICIPATIONS.BOOKING_NAME",
    CAST ( b.ACTIVITY AS VARCHAR(255))                                                  AS "PARTICIPATIONS.BOOKING_ACTIVITY",
    ac.NAME                                                                             AS "PARTICIPATIONS.BOOKING_ACTIVITY_NAME",
    p.CENTER                                                                            AS "PARTICIPATIONS.CENTER_ID",
    TO_CHAR(longtodateC(p.CREATION_TIME,p.CENTER), 'dd.MM.yyyy HH24:MI:SS')             AS "PARTICIPATIONS.CREATION_DATE_TIME" ,
    p.STATE                                                                             AS "PARTICIPATIONS.STATE",
    BI_DECODE_FIELD('PARTICIPATIONS','USER_INTERFACE_TYPE',p.USER_INTERFACE_TYPE)       AS "PARTICIPATIONS.USER_INTERFACE_TYPE",
    TO_CHAR(longtodateC(p.SHOWUP_TIME, p.CENTER), 'dd.MM.yyyy HH24:MI:SS')              AS "PARTICIPATIONS.SHOW_UP_TIME",
    BI_DECODE_FIELD('PARTICIPATIONS','SHOWUP_INTERFACE_TYPE',p.SHOWUP_INTERFACE_TYPE)   AS "PARTICIPATIONS.SHOW_UP_INTERFACE_TYPE",
    CASE p.SHOWUP_USING_CARD
        WHEN 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END                                                                                 AS "PARTICIPATIONS.SHOWUP_USING_CARD",
    TO_CHAR(longtodateC(p.CANCELATION_TIME, p.CENTER), 'dd.MM.yyyy HH24:MI:SS')         AS "PARTICIPATIONS.CANCEL_TIME",
    BI_DECODE_FIELD('PARTICIPATIONS','CANCELATION_INTERFACE_TYPE',p.CANCELATION_INTERFACE_TYPE) AS "PARTICIPATIONS.CANCEL_INTERFACE_TYPE",
    p.CANCELATION_REASON AS "PARTICIPATIONS.CANCEL_REASON",
    CASE p.ON_WAITING_LIST
        WHEN 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END                                                                                 AS "PARTICIPATIONS.WAS_ON_WAITING_LIST",
    TO_CHAR(longtodateC(p.MOVED_UP_TIME,p.CENTER), 'dd.MM.yyyy HH24:MI:SS')             AS "PARTICIPATIONS.SEAT_OBTAINED_DATETIME",
    CAST( p.participation_number AS VARCHAR(255))                                       AS "PARTICIPATIONS.PARTICIPANT_NUMBER",
    bs.ref                                                                              AS "PARTICIPATIONS.SEAT_ID",
    p.SEAT_STATE                                                                        AS "PARTICIPATIONS.SEAT_STATE",
    TO_CHAR(longToDatetz(p.LAST_MODIFIED,cen.time_zone), 'dd.MM.yyyy HH24:MI:SS')       AS "PARTICIPATIONS.LAST_UPDATED_EXERP"    
FROM
    PARTICIPATIONS p
JOIN
    BOOKINGS b
ON
    p.BOOKING_CENTER = b.CENTER
AND p.BOOKING_ID = b.ID
JOIN
    ACTIVITY ac
ON ac.ID = b.ACTIVITY
JOIN
    CENTERS cen
ON
    p.CENTER = cen.ID
LEFT JOIN
    persons per
ON
    per.CENTER = p.PARTICIPANT_CENTER
AND per.ID = p.PARTICIPANT_ID
LEFT JOIN
    BOOKING_SEATS bs
ON
    bs.ID = p.seat_id
JOIN
    params
ON
    params.CENTER_ID = cen.id    
WHERE    
    -- Exclude companies
    per.SEX != 'C'
    -- Exclude Transferred
AND per.external_id IS NOT NULL
    -- Exclude staff members
AND per.PERSONTYPE NOT IN (2,10)
AND p.LAST_MODIFIED > params.FROM_DATE
    