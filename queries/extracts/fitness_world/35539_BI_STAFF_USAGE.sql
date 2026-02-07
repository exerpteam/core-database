-- This is the version from 2026-02-05
--  
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                 AS TODATE
        
    )
SELECT
    CAST ( s.ID AS VARCHAR(255))                                                 AS "STAFF_USAGE_ID",
    s.BOOKING_CENTER || 'bk' || s.BOOKING_ID                                     AS "BOOKING_ID",
    s.BOOKING_CENTER                                                             AS "CENTER_ID",
    cp.EXTERNAL_ID                                                               AS "PERSON_ID",
    s.STATE                                                                      AS "STATE",
    TO_CHAR(longtodateC(s.STARTTIME, s.BOOKING_CENTER), 'YYYY-MM-DD HH24:MI:SS') AS "START_DATE_TIME",
    TO_CHAR(longtodateC(s.STOPTIME, s.BOOKING_CENTER), 'YYYY-MM-DD HH24:MI:SS')  AS "STOP_DATE_TIME",
    REPLACE(REPLACE(REPLACE(to_char(s.SALARY , 'FM999G999G999G999G990D00'), '.', '|'), ',', '.'),'|',',')   AS "SALARY",
    REPLACE(TO_CHAR(b.LAST_MODIFIED,'FM999G999G999G999G999'),',','.')            AS "ETS"
FROM
    PARAMS, STAFF_USAGE s
JOIN
    BOOKINGS b
ON
    s.BOOKING_CENTER = b.CENTER
    AND s.BOOKING_ID = b.ID
JOIN
    CENTERS c
ON
    s.BOOKING_CENTER = c.ID
JOIN
    persons per
ON
    per.CENTER = s.PERSON_CENTER
    AND per.ID = s.PERSON_ID
JOIN
    PERSONS cp
ON
    cp.CENTER = per.CURRENT_PERSON_CENTER
    AND cp.id = per.CURRENT_PERSON_ID
WHERE
    b.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE

