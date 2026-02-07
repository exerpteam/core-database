SELECT
    p.PARTICIPANT_CENTER||'p'||p.PARTICIPANT_ID                                                                                                             AS MEMBER_ID,
    TO_CHAR(longtodateC(p.START_TIME, p.center), 'yyyy-MM-dd hh24:mi')                                                                                      AS CLASS_START_TIME,
    TO_CHAR(longtodateC(p.SHOWUP_TIME, p.center), 'yyyy-MM-dd hh24:mi')                                                                                     AS SHOW_UP_TIME,
    DECODE (p.SHOWUP_USING_CARD,1,'YES','NO')                                                                                                               AS CARD_SWIPED,
    DECODE(p.PROCESSED_AUTOSHOWUP_JOB ,1,'YES','NO')                                                                                                        AS PROCESSED_BY_BATCHJOB,
    DECODE (p.SHOWUP_INTERFACE_TYPE, 0,'OTHER', 1,'CLIENT',2,'WEB',3,'KIOSK',4,'SCRIPT',5,'API',6,'MOBILE API','UNKNOWN')                                   AS SHOWUP_INTERFACE_TYPE,
    b.CENTER||'book'||b.ID                                                                                                                                  AS BOOKING_ID,
    b.NAME                                                                                                                                                  AS CLASS_NAME,
    p.STATE                                                                                                                                                 AS PARTICIPATION_STATE,
    btc.PART_SHOWUP_START_VALUE||' '||DECODE(btc.PART_SHOWUP_START_UNIT, 0, 'Week', 1, 'Days', 2, 'Month', 3, 'Year', 4, 'Hour', 5, 'Minutes', 6, 'Second') AS SHOW_UP_START
FROM
    PARTICIPATIONS p
JOIN
    BOOKINGS b
ON
    b.CENTER = p.BOOKING_CENTER
    AND b.ID = p.BOOKING_ID
JOIN
    ACTIVITY a
ON
    b.ACTIVITY = a.id
JOIN
    BOOKING_TIME_CONFIGS btc
ON
    a.TIME_CONFIG_ID = btc.id
WHERE
    p.SHOWUP_TIME > :ShowUpEarliestTime
