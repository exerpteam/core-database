WITH
    params AS
    (
        SELECT
            /*+ materialize */
            c.id,
            CAST(dateToLongC(TO_CHAR(now(), 'YYYY-MM-DD HH24:MI') , c.id) AS BIGINT)+2*3600*1000 AS currentTime,
            300*60*1000                                                              AS MaxDuration
        FROM
            centers c
    )
SELECT
    c.CHECKIN_CENTER,
    CASE GROUPING(CE.NAME)
        WHEN 1
        THEN 'Total'
        ELSE ce.name
    END                                      AS "Club",
    COUNT(c.PERSON_CENTER||'p'||c.PERSON_ID) AS "Member count",
    COUNT(par.PARTICIPANT_ID)                AS "TotalInClasses"
FROM
    CHECKINS c
JOIN
    params
ON
    params.id = c.CHECKIN_CENTER
JOIN
    CENTERS ce
ON
    ce.id = c.CHECKIN_CENTER
LEFT JOIN
    PARTICIPATIONS par
ON
    c.PERSON_CENTER = par.PARTICIPANT_CENTER
    AND c.PERSON_ID = par.PARTICIPANT_ID
    AND par.START_TIME <= PARAMS.currentTime
   AND par.STOP_TIME >= PARAMS.currentTime
    AND par.STATE <> 'CANCELLED'
WHERE
    c.CHECKIN_CENTER IN ($$Scope$$)
    AND
    -- checkin less than maxduration before the report time
    c.CHECKIN_TIME BETWEEN (PARAMS.currentTime - PARAMS.MaxDuration) AND PARAMS.currentTime
    AND (
        c.CHECKOUT_TIME IS NULL
        OR c.CHECKOUT_TIME > PARAMS.currentTime)
    AND CHECKIN_RESULT !=0
GROUP BY
    rollup( (c.CHECKIN_CENTER, ce.name))
ORDER BY
    name