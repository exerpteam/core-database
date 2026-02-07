SELECT
    c.CHECKIN_CENTER,
    DECODE(GROUPING(CE.NAME),1,'Total',ce.name) AS "Club",
    COUNT(c.PERSON_CENTER||'p'||c.PERSON_ID)    AS "Member count",
    COUNT(par.PARTICIPANT_ID) AS "TotalInClasses"
FROM
    (
        SELECT
            DATETOLONGTZ(TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI'),'Europe/London') AS currentTime,
            300*60*1000                                                         AS MaxDuration
        FROM
            dual) params
CROSS JOIN
    PUREGYM.CHECKINS c
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
    c.CHECKIN_CENTER IN ( :scope
                         --1,2,3
                         )
AND
    -- checkin less than maxduration before the report time
    c.CHECKIN_TIME BETWEEN (PARAMS.currentTime - PARAMS.MaxDuration) AND PARAMS.currentTime
AND (
        c.CHECKOUT_TIME IS NULL
    OR  c.CHECKOUT_TIME > PARAMS.currentTime)
AND CHECKIN_RESULT !=0
    
    GROUP BY
        rollup( (c.CHECKIN_CENTER, ce.name))
    ORDER BY
        name