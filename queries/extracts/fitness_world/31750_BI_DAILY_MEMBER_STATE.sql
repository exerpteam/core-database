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
    cp.EXTERNAL_ID                                                                                                 AS "PERSON_ID",
    dms.PERSON_CENTER                                                                                              AS "CENTER_ID",
    dms.PERSON_ID                                                                                                  AS "HOME_CENTER_PERSON_ID",
    TO_CHAR(dms.CHANGE_DATE,'yyyy-MM-dd ')||TO_CHAR(longtodateC(dms.ENTRY_START_TIME,dms.PERSON_CENTER),'HH24:MI') AS "CHANGE_DATETIME",
    BI_DECODE_FIELD('DAILY_MEMBER_STATUS_CHANGES','CHANGE',dms.CHANGE)                                             AS "CHANGE",
    dms.MEMBER_NUMBER_DELTA                                                                                        AS "MEMBER_NUMBER_DELTA",
    dms.EXTRA_NUMBER_DELTA                                                                                         AS "EXTRA_NUMBER_DELTA",
    dms.SECONDARY_MEMBER_NUMBER_DELTA                                                                              AS "SECONDARY_MEMBER_NUMBER_DELTA",
    REPLACE(TO_CHAR(dms.ENTRY_START_TIME ,'FM999G999G999G999G999'),',','.')                                        AS "ETS"    
FROM
    params,
    DAILY_MEMBER_STATUS_CHANGES dms
JOIN
    PERSONS p
ON
    p.CENTER = dms.PERSON_CENTER
    AND p.id = dms.PERSON_ID
JOIN
    PERSONS cp
ON
    cp.center = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
WHERE
    dms.ENTRY_STOP_TIME IS NULL
    AND dms.ENTRY_START_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
