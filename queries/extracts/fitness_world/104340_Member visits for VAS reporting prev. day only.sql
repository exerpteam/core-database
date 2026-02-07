-- This is the version from 2026-02-05
--  
WITH
    params AS Materialized
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE CAST(datetolong(to_char(current_date-1,'YYYY-MM-DD HH24:MI')) AS BIGINT) END AS FROMDATE,
            CAST(datetolong(to_char(current_date,'YYYY-MM-DD HH24:MI')) AS BIGINT) AS TODATE
    )
SELECT
CASE P.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 
        'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONE MAN CORPORATE' WHEN 6 THEN 
        'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' ELSE 
        'UNKNOWN' END AS PERSONTYPE,
    CAST(c.ID AS VARCHAR(255))                                         AS "VISIT_ID",
    c.CHECKIN_CENTER                                                     AS "CENTER_ID",
    cp.EXTERNAL_ID                                                       AS "PERSON_ID",
    CAST(p.CENTER AS VARCHAR(255))                                     AS "MEMBER_HOME_CLUB",
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER), 'yyyy-MM-dd') AS "CHECK_IN_DATE",
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER), 'HH24:MI:SS') AS "CHECK_IN_TIME",
    TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER), 'yyyy-MM-dd') AS "CHECK_OUT_DATE",
    TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER), 'HH24:MI:SS') AS "CHECK_OUT_TIME",
    BI_DECODE_FIELD('CHECKINS', 'CHECKIN_RESULT', c.CHECKIN_RESULT)      AS "CHECK_IN_RESULT",
    CASE
        WHEN c.CARD_CHECKED_IN = 1
        THEN 'TRUE'
        ELSE 'FALSE'
    END AS "CARD_CHECKED_IN",
    REPLACE(TO_CHAR(c.CHECKIN_TIME, 'FM999G999G999G999G999'), ',', '.') AS "ETS",
    CASE
        WHEN c.CHECKIN_CENTER <> p.CENTER THEN 'TRUE'
        ELSE 'FALSE'
    END AS "non-local visit" -- New column indicating if the visit is non-local
FROM
    params,
    CHECKINS c
JOIN
    PERSONS p ON p.CENTER = c.PERSON_CENTER AND p.id = c.PERSON_ID
JOIN
    PERSONS cp ON cp.CENTER = p.CURRENT_PERSON_CENTER AND cp.id = p.CURRENT_PERSON_ID
WHERE
    c.CHECKIN_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
and p.center in (:MEMBER_HOME_CLUB)