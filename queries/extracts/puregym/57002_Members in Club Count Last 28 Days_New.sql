WITH
    params AS
    (
        SELECT
            CAST(datetolongTZ(TO_CHAR(CURRENT_DATE - interval '28 days','YYYY-MM-DD HH24:MI'),
            'UTC') AS BIGINT)                                                          AS from_date,
            CAST(dateToLongTZ(TO_CHAR(CURRENT_DATE,'YYYY-MM-DD HH24:MI'), 'UTC') AS BIGINT) AS
            to_date
    )
    ,
    slot_series AS Materialized
    (
        SELECT
            *
        FROM
            generate_series((CURRENT_DATE - INTERVAL '28 days' + INTERVAL '1 hour'), (CURRENT_DATE
            - INTERVAL '1 hour'), '1 hours') AS d1
    )
    ,
    slots AS Materialized
    (
        SELECT
            CAST(dateToLongTZ(TO_CHAR(s.d1 , 'YYYY-MM-DD HH24:MI') , 'UTC') AS BIGINT) AS
            lower_bound,
            CAST(dateToLongTZ(TO_CHAR((s.d1 + INTERVAL '1 hour'), 'YYYY-MM-DD HH24:MI'), 'UTC') AS
            BIGINT)                    AS higher_bound,
            s.d1                       AS lower_date_time,
            (s.d1 + INTERVAL '1 hour') AS higher_date_time
        FROM
            slot_series s
    )
    ,
    V_CHECK_IN AS Materialized
    (
        SELECT
            c.id,
            c.CHECKIN_CENTER,
            c.PERSON_CENTER,
            c.PERSON_ID,
            c.CHECKIN_TIME,
            c.CHECKOUT_TIME,
            par.center,
            par.participant_center,
            par.PARTICIPANT_ID,
            par.participant_center||'p'||par.PARTICIPANT_ID,
            par.START_TIME,
            par.STOP_TIME,
            c.CHECKOUT_TIME - mod(c.CHECKOUT_TIME, 1000*60*60) + 1000*60*60 AS higher_bound,
            c.CHECKIN_TIME - mod(c.CHECKIN_TIME, 1000*60*60)                AS lower_bound
        FROM
            params,
            CHECKINS c
        JOIN
            persons p
        ON
            p.CENTER = c.PERSON_CENTER
        AND p.ID = c.PERSON_ID
        LEFT JOIN
            PARTICIPATIONS par
        ON
            c.PERSON_CENTER = par.PARTICIPANT_CENTER
        AND c.PERSON_ID = par.PARTICIPANT_ID
        AND par.START_TIME <= c.CHECKOUT_TIME - mod(c.CHECKOUT_TIME, 1000*60*60) + 1000*60*60
        AND par.STOP_TIME >= c.CHECKIN_TIME - mod(c.CHECKIN_TIME, 1000*60*60)
        AND par.STATE <> 'CANCELLED'
        AND par.center IN (:Scope)
        WHERE
            p.PERSONTYPE != 2
        AND c.CHECKIN_CENTER IN (:Scope)
        AND c.CHECKIN_TIME BETWEEN params.from_date AND params.to_date
        AND c.checkin_result IN (0,1)
    )
SELECT
    c.SHORTNAME                                  club_name ,
    c.ID                                         club_id ,
    TO_CHAR(lower_date_time,'YYYY-MM-DD HH24')   from_time ,
    TO_CHAR(higher_date_time ,'YYYY-MM-DD HH24') to_time,
    COUNT(cin.id)                                checkins ,
    SUM(
        CASE
            WHEN cin.start_time <= slots.higher_bound
            AND cin.stop_time >= slots.lower_bound
            THEN 1
            ELSE 0
        END) AS "TotalInClasses"
FROM
    V_CHECK_IN cin
CROSS JOIN
    slots
JOIN
    CENTERS c
ON
    c.id = cin.CHECKIN_CENTER
WHERE
    cin.CHECKIN_TIME <= slots.higher_bound
AND cin.CHECKOUT_TIME >= slots.lower_bound
GROUP BY
    lower_date_time ,
    higher_date_time ,
    c.id ,
    c.SHORTNAME
ORDER BY
    c.ID,
    lower_date_time