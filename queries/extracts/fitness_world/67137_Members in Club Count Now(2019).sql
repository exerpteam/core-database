-- This is the version from 2026-02-05
--  
WITH
    dayOfWeek AS
    (
        SELECT
            TRIM(TO_CHAR(ADD_MONTHS(TO_DATE(getcentertime(100),'YYYY-MM-DD HH24:MI'), -24),'day'))   AS DOW,
            ADD_MONTHS(TO_DATE(getcentertime(100),'YYYY-MM-DD HH24:MI'), -24)                        AS TODAY,
            TO_CHAR(ADD_MONTHS(TO_DATE(getcentertime(100),'YYYY-MM-DD HH24:MI'), -24), 'YYYY-MM-DD') AS TODAY_DATE_CHAR
        FROM
            DUAL
    )
SELECT
    t1.CHECKIN_CENTER,
    DECODE(GROUPING(t1.club),1,'Total',t1.club) AS Club,
    SUM(t1."Member count")                      AS "Member Count",
    SUM(t1."TotalInClasses")                    AS "Total In Classes"
FROM
    (
        SELECT
            c.CHECKIN_CENTER,
            DECODE(GROUPING(CE.NAME),1,'Total',ce.name) AS Club,
            COUNT(c.PERSON_CENTER||'p'||c.PERSON_ID)    AS "Member count",
            COUNT(par.PARTICIPANT_ID)                   AS "TotalInClasses"
        FROM
            (
                SELECT
                    DATETOLONGC(TO_CHAR(ADD_MONTHS(TO_DATE(getcentertime(100),  'YYYY-MM-DD HH24:MI'), -24), 'YYYY-MM-DD HH24:MI'), 100)                     AS currentTime,
                    TRUNC(ADD_MONTHS(TO_DATE(getcentertime(100),'YYYY-MM-DD HH24:MI'), -24)) AS currentDate,
                    60*60*1000                                             AS MaxDuration
                FROM
                    dual ) params
        CROSS JOIN
            CHECKINS c
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
            c.CHECKIN_CENTER IN ( :scope )
            AND ce.STARTUPDATE < PARAMS.currentDate
            AND
            -- checkin less than maxduration before the report time
            c.CHECKIN_TIME BETWEEN (PARAMS.currentTime - PARAMS.MaxDuration) AND PARAMS.currentTime
            AND CHECKIN_RESULT !=0
        GROUP BY
            c.CHECKIN_CENTER,
            ce.name ) t1
CROSS JOIN
    dayOfWeek
LEFT JOIN
    (
        WITH
            topscope AS
            (
                SELECT
                    s.ID,
                    s.GLOBALID,
                    s.SCOPE_TYPE,
                    s.SCOPE_ID,
                    s.CLIENT,
                    s.TXTVALUE,
                    s.MIMETYPE,
                    s.LINK_TYPE,
                    s.LINK_ID,
                    avail.from_col AS FROM_TIME,
                    avail.to_col   AS TO_TIME
                FROM
                    SYSTEMPROPERTIES s
                LEFT JOIN
                    XMLTABLE('//SIMPLETIMEINTERVAL' passing XMLType(s.MIMEVALUE,871) columns from_col VARCHAR2(10) PATH '@FROM', to_col VARCHAR2(50) PATH '@TO', thisday VARCHAR2(50) PATH '../name(.)' ) avail
                ON
                    1 = 1
                WHERE
                    s.GLOBALID = 'CenterOpeningHours'
                    AND s.TXTVALUE = 'dk.procard.eclub.time.schedule.DailySchedule'
                    AND s.SCOPE_TYPE = 'T'
            )
        SELECT
            c.ID,
            oh.TXTVALUE,
            (
                CASE
                    WHEN oh.ID IS NULL
                    THEN topscope.FROM_TIME
                    ELSE oh.FROM_TIME
                END) AS FROM_TIME,
            (
                CASE
                    WHEN oh.ID IS NULL
                    THEN topscope.TO_TIME
                    ELSE oh.TO_TIME
                END) AS TO_TIME,
            oh.DAY_OF_WEEK
        FROM
            CENTERS c
        CROSS JOIN
            topscope
        LEFT JOIN
            (
                SELECT
                    s.ID,
                    s.GLOBALID,
                    s.SCOPE_TYPE,
                    s.SCOPE_ID,
                    s.CLIENT,
                    s.TXTVALUE,
                    s.MIMETYPE,
                    s.LINK_TYPE,
                    s.LINK_ID,
                    avail.from_col AS FROM_TIME,
                    avail.to_col   AS TO_TIME,
                    NULL           AS DAY_OF_WEEK
                FROM
                    SYSTEMPROPERTIES s
                LEFT JOIN
                    XMLTABLE('//BUSINESS/SIMPLETIMEINTERVAL' passing XMLType(s.MIMEVALUE,871) columns from_col VARCHAR2(10) PATH '@FROM', to_col VARCHAR2(50) PATH '@TO', thisday VARCHAR2(50) PATH '../name(.)' ) avail
                ON
                    1 = 1
                WHERE
                    s.GLOBALID = 'CenterOpeningHours'
                    AND s.TXTVALUE = 'dk.procard.eclub.time.schedule.BusinessSchedule'
                UNION ALL
                SELECT
                    s.ID,
                    s.GLOBALID,
                    s.SCOPE_TYPE,
                    s.SCOPE_ID,
                    s.CLIENT,
                    s.TXTVALUE,
                    s.MIMETYPE,
                    s.LINK_TYPE,
                    s.LINK_ID,
                    avail.from_col AS FROM_TIME,
                    avail.to_col   AS TO_TIME,
                    NULL           AS DAY_OF_WEEK
                FROM
                    SYSTEMPROPERTIES s
                LEFT JOIN
                    XMLTABLE('//SIMPLETIMEINTERVAL' passing XMLType(s.MIMEVALUE,871) columns from_col VARCHAR2(10) PATH '@FROM', to_col VARCHAR2(50) PATH '@TO', thisday VARCHAR2(50) PATH '../name(.)' ) avail
                ON
                    1 = 1
                WHERE
                    s.GLOBALID = 'CenterOpeningHours'
                    AND s.TXTVALUE = 'dk.procard.eclub.time.schedule.DailySchedule'
                UNION ALL
                SELECT
                    s.ID,
                    s.GLOBALID,
                    s.SCOPE_TYPE,
                    s.SCOPE_ID,
                    s.CLIENT,
                    s.TXTVALUE,
                    s.MIMETYPE,
                    s.LINK_TYPE,
                    s.LINK_ID,
                    avail.from_col AS FROM_TIME,
                    avail.to_col   AS TO_TIME,
                    avail.thisday  AS DAY_OF_WEEK
                FROM
                    SYSTEMPROPERTIES s
                LEFT JOIN
                    XMLTABLE('//SIMPLETIMEINTERVAL' passing XMLType(s.MIMEVALUE,871) columns from_col VARCHAR2(10) PATH '@FROM', to_col VARCHAR2(50) PATH '@TO', thisday VARCHAR2(50) PATH '../name(.)' ) avail
                ON
                    1 = 1
                WHERE
                    s.GLOBALID = 'CenterOpeningHours'
                    AND s.TXTVALUE = 'dk.procard.eclub.time.schedule.WeeklySchedule'
                    AND s.MIMETYPE = 'text/xml' ) oh
        ON
            oh.SCOPE_TYPE = 'C'
            AND c.ID = oh.SCOPE_ID ) t2
ON
    t1.CHECKIN_CENTER = t2.ID
WHERE
    (
        t2.TXTVALUE IS NULL
        OR t2.TXTVALUE != 'dk.procard.eclub.time.schedule.WeeklySchedule'
        OR (
            t2.TXTVALUE = 'dk.procard.eclub.time.schedule.WeeklySchedule'
            AND t2.DAY_OF_WEEK = dayOfWeek.DOW ) )
    AND (
        TO_DATE(dayOfWeek.TODAY_DATE_CHAR || t2.FROM_TIME,'YYYY-MM-DD HH24:MI') < dayOfWeek.TODAY
        AND TO_DATE(dayOfWeek.TODAY_DATE_CHAR || t2.TO_TIME,'YYYY-MM-DD HH24:MI') > dayOfWeek.TODAY )
GROUP BY
    rollup( (t1.CHECKIN_CENTER, t1.club))
ORDER BY
    t1.club
