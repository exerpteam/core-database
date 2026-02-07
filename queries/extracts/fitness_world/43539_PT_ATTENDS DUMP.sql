-- This is the version from 2026-02-05
--  
SELECT
    biview.*
FROM
    (
        SELECT
            att.CENTER || 'att' || att.ID AS                                    "PT_ATTEND_ID",
            cp.EXTERNAL_ID                                                      "PERSON_ID",
            TO_CHAR(exerpro.longtodate(att.START_TIME),'yyyy-MM-dd HH24:MI:SS') "START_TIME",
            TO_CHAR(exerpro.longtodate(att.STOP_TIME),'yyyy-MM-dd HH24:MI:SS')  "STOP_TIME",
            br.CENTER||'br'||br.id AS                                           "RESOURCE_ID",
            att.CENTER                                                          "CENTER_ID",
            att.LAST_MODIFIED AS                                                "ETS"
        FROM
            BOOKING_RESOURCES br
        JOIN
            BOOKING_PRIVILEGE_GROUPS bpg
        ON
            bpg.ID = br.ATTEND_PRIVILEGE_ID
        JOIN
            ATTENDS att
        ON
            att.BOOKING_RESOURCE_CENTER = br.center
            AND att.BOOKING_RESOURCE_ID = br.id
        JOIN
            PERSONS p
        ON
            p.center = att.PERSON_CENTER
            AND p.id = att.PERSON_ID
        JOIN
            PERSONS cp
        ON
            cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
            AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
        WHERE
            br.ATTEND_PRIVILEGE_ID = 61 -- = 'Club, Personal Training
    ) biview