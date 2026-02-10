-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    att.CENTER || 'att' || att.ID AS                                        "ATTEND_ID",
    cp.EXTERNAL_ID                                                          "PERSON_ID",
    TO_CHAR(longtodateC(att.START_TIME,att.center),'yyyy-MM-dd HH24:MI:SS') "START_TIME",
    TO_CHAR(longtodateC(att.STOP_TIME,att.center),'yyyy-MM-dd HH24:MI:SS')  "STOP_TIME",
    att.BOOKING_RESOURCE_CENTER||'br'||att.BOOKING_RESOURCE_ID AS           "RESOURCE_ID",
    att.CENTER                                                              "CENTER_ID",
    att.LAST_MODIFIED AS                                                    "ETS"
FROM
    ATTENDS att
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
where 
att.START_TIME >= $$from_time$$
AND  att.START_TIME < $$to_time$$
