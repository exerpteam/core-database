-- This is the version from 2026-02-05
--  
WITH
    PARAMS AS MATERIALIZED
    (
        SELECT
            CAST(dateToLongC(TO_CHAR(TO_DATE(:fromdate, 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id ) AS
            bigint) AS fromDate,
            CAST(dateToLongC(TO_CHAR(TO_DATE(:todate, 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id ) AS bigint
            )+(1000*60*60*24)-1 AS toDate,
            c.id              AS centerID,
            c.name            AS Centername
        FROM
            centers c
            JOIN
             AREA_CENTERS ac
             on
             ac.center = c.id
             join AREAS a
             on
           ac.area = a.id
          and a.root_area = 1
       and a.id not in (33,34,37,39,133)
       and a.blocked != 'true'
            where ac.area in (17,12,3,16,422,425,427,134,6,421,231,426,335,4,424,433,435,436,337,420,5)
             and c.country = 'DK' and (c.id in (:MEMBER_HOME_CLUB)) 
    )
SELECT distinct
    CASE P.PERSONTYPE 
        WHEN 0 THEN 'PRIVATE' 
        WHEN 1 THEN 'STUDENT' 
        WHEN 2 THEN 'STAFF' 
        WHEN 3 THEN 'FRIEND' 
        WHEN 4 THEN 'CORPORATE' 
        WHEN 5 THEN 'ONE MAN CORPORATE' 
        WHEN 6 THEN 'FAMILY' 
        WHEN 7 THEN 'SENIOR' 
        WHEN 8 THEN 'GUEST' 
        ELSE 'UNKNOWN' 
    END AS PERSONTYPE,
    CAST(c.ID AS VARCHAR(255)) AS "VISIT_ID",
    c.CHECKIN_CENTER AS "CENTER_ID",
    cp.EXTERNAL_ID AS "PERSON_ID",
    CAST(p.CENTER AS VARCHAR(255)) AS "MEMBER_HOME_CLUB",
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER), 'yyyy-MM-dd') AS "CHECK_IN_DATE",
    TO_CHAR(longtodateC(c.CHECKIN_TIME, c.CHECKIN_CENTER), 'HH24:MI:SS') AS "CHECK_IN_TIME",
    TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER), 'yyyy-MM-dd') AS "CHECK_OUT_DATE",
    TO_CHAR(longtodateC(c.CHECKOUT_TIME, c.CHECKIN_CENTER), 'HH24:MI:SS') AS "CHECK_OUT_TIME",
    BI_DECODE_FIELD('CHECKINS', 'CHECKIN_RESULT', c.CHECKIN_RESULT) AS "CHECK_IN_RESULT",
    CASE
        WHEN c.CARD_CHECKED_IN = 1 THEN 'TRUE'
        ELSE 'FALSE'
    END AS "CARD_CHECKED_IN",
    REPLACE(TO_CHAR(c.CHECKIN_TIME, 'FM999G999G999G999G999'), ',', '.') AS "ETS",
    CASE
        WHEN c.CHECKIN_CENTER <> p.CENTER THEN 'TRUE'
        ELSE 'FALSE'
    END AS "non-local visit" -- New column indicating if the visit is non-local
FROM CHECKINS c

join params
on params.centerid = c.person_center 

JOIN
    PERSONS p ON p.CENTER = c.PERSON_CENTER AND p.id = c.PERSON_ID
JOIN
    PERSONS cp ON cp.CENTER = p.CURRENT_PERSON_CENTER AND cp.id = p.CURRENT_PERSON_ID
  
    
WHERE
    c.CHECKIN_TIME BETWEEN params.FROMDATE AND params.TODATE
    AND p.CENTER IN (:MEMBER_HOME_CLUB)