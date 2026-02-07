-- This is the version from 2026-02-05
--  
WITH
    params AS Materialized
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE CAST(datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$, 'yyyy-MM-dd HH24:MI')) AS BIGINT) END AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI')) AS BIGINT) AS TODATE
    )
SELECT
    CAST ( c.ID AS VARCHAR(255))                                         "VISIT_ID",
    c.CHECKIN_CENTER                                                     "CENTER_ID",
    cp.EXTERNAL_ID                                                       "PERSON_ID",
    CAST ( p.CENTER AS VARCHAR(255))                                     "HOME_CENTER_ID",
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),'yyyy-MM-dd')  "CHECK_IN_DATE",
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER),'HH24:MI:SS')  "CHECK_IN_TIME",
    TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER),'yyyy-MM-dd') "CHECK_OUT_DATE",
    TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER),'HH24:MI:SS') "CHECK_OUT_TIME",
    BI_DECODE_FIELD('CHECKINS','CHECKIN_RESULT',c.CHECKIN_RESULT)        "CHECK_IN_RESULT",
    CASE
        WHEN c.CARD_CHECKED_IN = 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS         "CARD_CHECKED_IN",
    REPLACE(TO_CHAR(c.CHECKIN_TIME,'FM999G999G999G999G999'),',','.') AS   "ETS"
FROM
    params,
    CHECKINS c
JOIN
    PERSONS p
ON
    p.CENTER = c.PERSON_CENTER
    AND p.id = c.PERSON_ID
JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
WHERE
    c.CHECKIN_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
