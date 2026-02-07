select
att.CENTER || 'att' || att.ID AS "ID",
    CASE
        WHEN (p.CENTER != p.TRANSFERS_CURRENT_PRS_CENTER
                OR p.id != p.TRANSFERS_CURRENT_PRS_ID )
        THEN
            (
                SELECT
                    EXTERNAL_ID
                FROM
                    PERSONS
                WHERE
                    CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND ID = p.TRANSFERS_CURRENT_PRS_ID)
        ELSE p.EXTERNAL_ID
    END AS                                                        "PERSON_ID",
    TO_CHAR(longtodateC(att.START_TIME,att.center),'yyyy-MM-dd HH24:MI:SS') "START_TIME",
    TO_CHAR(longtodateC(att.STOP_TIME,att.center),'yyyy-MM-dd HH24:MI:SS')  "STOP_TIME",
    att.BOOKING_RESOURCE_CENTER||'br'||att.BOOKING_RESOURCE_ID AS "RESOURCE_ID",
    att.CENTER                                                    "CENTER_ID",
    att.LAST_MODIFIED AS                                          "ETS"
FROM
    ATTENDS att
JOIN
    PERSONS p
ON
    p.center = att.PERSON_CENTER
    AND p.id = att.PERSON_ID

WHERE
    att.START_TIME >= $$FROMDATE$$ 
    AND att.START_TIME < $$TODATE$$
    AND att.CENTER in ($$scope$$)