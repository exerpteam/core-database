SELECT
    c.CHECKIN_CENTER,
    DECODE(GROUPING(CE.NAME),1,'Total',ce.name) AS "Club",
    COUNT(c.PERSON_CENTER||'p'||c.PERSON_ID)    AS "Member count"
FROM
    (
        SELECT
            DATETOLONGTZ(TO_CHAR( $$Checkdate$$,'YYYY-MM-DD HH24:MI'),'Europe/London')  AS currentTime,
            3*3600*1000                                                         AS MaxDuration
        FROM
            dual) params,
    PUREGYM.CHECKINS c
    /**JOIN
    PERSONS P
    ON
    P.center = c.PERSON_CENTER
    AND p.id = c.PERSON_ID **/
JOIN
    CENTERS ce
ON
    ce.id = c.CHECKIN_CENTER
WHERE
    c.CHECKIN_CENTER IN ( :scope
                         --1,2,3
                         )
AND
    -- checkin less than maxduration before the report time
    c.CHECKIN_TIME BETWEEN (PARAMS.currentTime - PARAMS.MaxDuration) AND PARAMS.currentTime
AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PUREGYM.ATTENDS a
        JOIN
            PUREGYM.BOOKING_RESOURCES r
        ON
            r.CENTER = a.BOOKING_RESOURCE_CENTER
        AND r.id = a.BOOKING_RESOURCE_ID
        AND r.NAME LIKE '%Out%'
        WHERE
            a.CENTER = c.CHECKIN_CENTER
        AND a.PERSON_CENTER = c.PERSON_CENTER
        AND a.PERSON_ID = c.PERSON_ID
            -- checkout within 3 hours, after the report time (person still in the club)
        AND a.START_TIME BETWEEN c.CHECKIN_TIME AND currentTime )
GROUP BY
    rollup( (c.CHECKIN_CENTER, ce.name))
ORDER BY
    name