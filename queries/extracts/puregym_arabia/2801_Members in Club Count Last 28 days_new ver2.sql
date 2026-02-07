WITH
    params AS
    (
        SELECT
            c.id,
            CAST(dateToLong( cast(cast(getcentertime(c.id) AS TIMESTAMP) - interval '28 days' AS
            VARCHAR)) AS BIGINT)             AS from_date,
            CAST(dateToLong( getcentertime(c.id)) AS BIGINT) AS to_date
        FROM
            centers c
    )
    ,
    slot_series AS
    (
        SELECT
            *
        FROM
            generate_series((CAST(now() at time zone 'utc' AS DATE) - INTERVAL '28 days' + INTERVAL '1 hour'), (CAST
            (now()at time zone 'utc' AS DATE) - INTERVAL '1 hour'), '1 hours') AS d1
    )
    ,
    slots AS
    (
        SELECT distinct
			
            CAST(datetolong(TO_CHAR((s.d1 + INTERVAL '0 hour'), 'YYYY-MM-DD HH24:MI:SS'))
            AS BIGINT)  AS
            lower_bound,
            CAST(datetolong(TO_CHAR((s.d1 + INTERVAL '1 hour'), 'YYYY-MM-DD HH24:MI:SS'))
            AS BIGINT)                   AS higher_bound,
            (s.d1 - INTERVAL '2 hour')      AS lower_date_time,
            (s.d1 - INTERVAL '1 hour') AS higher_date_time
            
        FROM
            slot_series s, centers c
    )
    ,
    V_CHECK_IN AS
    (
        SELECT
            cin.*
        FROM
            CHECKINS cin
        JOIN
           persons p
        ON
            p.CENTER = cin.PERSON_CENTER
        AND p.ID = cin.PERSON_ID
        AND p.PERSONTYPE != 2
        JOIN
            params
        ON
            params.id = p.center
        WHERE
            cin.CHECKIN_CENTER IN (:scope)
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
    cin.CHECKIN_TIME between slots.lower_bound and slots.higher_bound
-- AND cin.CHECKOUT_TIME >= slots.lower_bound
GROUP BY
    lower_date_time ,
    higher_date_time ,
    c.id ,
    c.SHORTNAME
ORDER BY
    c.ID,
    lower_date_time