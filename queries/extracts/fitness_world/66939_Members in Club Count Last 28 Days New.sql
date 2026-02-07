-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            /*+ materialize */
            dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-28),'YYYY-MM-DD') || ' 00:00','UTC') from_date ,
            dateToLongTZ(TO_CHAR(TRUNC(SYSDATE),'YYYY-MM-DD') || ' 00:00','UTC')   to_date
        FROM
            dual
    )
    ,
    slots AS
    (
        SELECT
            /*+ materialize */
            dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-28),'YYYY-MM-DD') || ' 00:00','UTC') + ((level ) * 1000 * 60 * 60)                                  lower_bound ,
            dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-28),'YYYY-MM-DD') || ' 00:00','UTC') + ((level +1) * 1000 * 60 * 60) - 1                            higher_bound ,
            longToDateTZ(dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-28),'YYYY-MM-DD') || ' 00:00','UTC') + ((level) * 1000 * 60 * 60),'UTC')     lower_date_time ,
            longToDateTZ(dateToLongTZ(TO_CHAR(TRUNC(SYSDATE-28),'YYYY-MM-DD') || ' 00:00','UTC') + ((level + 1) * 1000 * 60 * 60),'UTC') higher_date_time
        FROM
            dual CONNECT BY level <= (24 * 28 - 1)
    )
    ,
    V_CHECK_IN AS
    (
        SELECT
            cin.*
        FROM
            CHECKINS cin
        JOIN
            PERSONS p
        ON
            p.CENTER = cin.PERSON_CENTER
            AND p.ID = cin.PERSON_ID
           -- AND p.PERSONTYPE != 2
        CROSS JOIN
            params
        WHERE
            cin.CHECKIN_CENTER IN ($$Scope$$)
            AND cin.CHECKIN_TIME BETWEEN params.from_date AND params.to_date
    )
SELECT
    c.SHORTNAME                                     club_name ,
    c.ID                                            club_id ,
    TO_CHAR(lower_date_time,'YYYY-MM-DD HH24')      from_time ,
   TO_CHAR(higher_date_time ,'YYYY-MM-DD HH24')    to_time,
    COUNT(1)                                        checkins ,
    COUNT(par.PARTICIPANT_ID)                    AS "TotalInClasses"
FROM
    V_CHECK_IN cin
CROSS JOIN
    slots
JOIN
    CENTERS c
ON
    c.id = cin.CHECKIN_CENTER
LEFT JOIN
    PARTICIPATIONS par
ON
    cin.PERSON_CENTER = par.PARTICIPANT_CENTER
    AND cin.PERSON_ID = par.PARTICIPANT_ID
    AND par.START_TIME <= slots.higher_bound
    AND par.STOP_TIME >= slots.lower_bound
    AND par.STATE <> 'CANCELLED'
WHERE
    cin.CHECKIN_TIME <= slots.higher_bound
    AND cin.CHECKIN_TIME >= slots.lower_bound
GROUP BY
    lower_date_time ,
    higher_date_time ,
    c.id ,
    c.SHORTNAME
ORDER BY
    c.ID,
    lower_date_time
