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
    att.CENTER || 'att' || att.ID AS                                        "ATTEND_ID",
    cp.EXTERNAL_ID                                                          "PERSON_ID",
    TO_CHAR(longtodateC(att.START_TIME,att.center),'yyyy-MM-dd HH24:MI:SS') "START_TIME",
    TO_CHAR(longtodateC(att.STOP_TIME,att.center),'yyyy-MM-dd HH24:MI:SS')  "STOP_TIME",
    att.BOOKING_RESOURCE_CENTER||'br'||att.BOOKING_RESOURCE_ID AS           "RESOURCE_ID",
    att.CENTER                                                              "CENTER_ID",
    TO_CHAR(att.LAST_MODIFIED,'FM999G999G999G999G999') AS "ETS"    
FROM
    params, ATTENDS att
LEFT JOIN
    PERSONS p
ON
    p.center = att.PERSON_CENTER
    AND p.id = att.PERSON_ID
LEFT JOIN
    PERSONS cp
ON
    cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID 
WHERE
    att.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
