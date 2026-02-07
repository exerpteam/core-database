-- This is the version from 2026-02-05
--  
WITH
    params AS  
    (
        SELECT
            CAST(datetolongTZ(to_char(current_date - interval '7 days','YYYY-MM-DD HH24:MI'), 'UTC') AS BIGINT) AS from_date,
            CAST(dateToLongTZ(to_char(current_date,'YYYY-MM-DD HH24:MI'), 'UTC') AS BIGINT) AS to_date
    )
    ,
    slot_series AS Materialized 
    (
        SELECT
            *
        FROM
            generate_series((current_date - INTERVAL '7 days' + INTERVAL '1 hour'), (current_date - INTERVAL '1 hour'), '1 hours') AS d1
    )
    ,
    slots AS Materialized 
    (
        SELECT 	
            CAST(dateToLongTZ(TO_CHAR(s.d1 , 'YYYY-MM-DD HH24:MI') , 'UTC') AS BIGINT)                    AS lower_bound,
            CAST(dateToLongTZ(TO_CHAR((s.d1 + INTERVAL '1 hour'), 'YYYY-MM-DD HH24:MI'), 'UTC') AS BIGINT) AS higher_bound,		
            s.d1                       AS lower_date_time,
            (s.d1 + INTERVAL '1 hour') AS higher_date_time
        FROM
            slot_series s
     )       

SELECT
    c.SHORTNAME                                     club_name ,
    c.ID                                            club_id ,
    TO_CHAR(lower_date_time,'YYYY-MM-DD HH24')      from_time ,
    TO_CHAR(higher_date_time ,'YYYY-MM-DD HH24')    to_time ,
    COUNT(1)                                        checkins ,
    COUNT(par.PARTICIPANT_ID)                    AS "TotalInClasses"
FROM
    CHECKINS cin
CROSS JOIN
    slots
JOIN
    CENTERS c
ON
    c.id = cin.CHECKIN_CENTER
JOIN
    PERSONS p
ON
    p.CENTER = cin.PERSON_CENTER
    AND p.ID = cin.PERSON_ID
    AND p.PERSONTYPE != 2
CROSS JOIN
    params
LEFT JOIN
    PARTICIPATIONS par
ON
    cin.PERSON_CENTER = par.PARTICIPANT_CENTER
    AND cin.PERSON_ID = par.PARTICIPANT_ID
    AND par.START_TIME <= slots.higher_bound
    AND par.STOP_TIME >= slots.lower_bound
    AND par.STATE <> 'CANCELLED'
WHERE
    cin.CHECKIN_CENTER IN ($$scope$$)
    AND cin.CHECKIN_TIME <= slots.higher_bound
    AND cin.CHECKIN_TIME >= slots.lower_bound
    AND cin.CHECKIN_TIME BETWEEN params.from_date AND params.to_date
GROUP BY
    lower_date_time ,
    higher_date_time ,
    c.id ,
    c.SHORTNAME
ORDER BY
    c.ID,
    lower_date_time
