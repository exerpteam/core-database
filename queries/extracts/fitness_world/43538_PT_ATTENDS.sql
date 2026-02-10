-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-3345
WITH
    params AS
    (
        SELECT
            CASE $$offset$$ WHEN -1 THEN 0 ELSE (TRUNC(current_timestamp)-$$offset$$-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint END AS FROMDATE,
            (TRUNC(current_timestamp+1)-to_date('01-01-1970','DD-MM-YYYY'))*24*3600*1000::bigint                                  AS TODATE
        
    )
SELECT
            att.CENTER || 'att' || att.ID AS                                    "PT_ATTEND_ID",
            cp.EXTERNAL_ID                                                      "PERSON_ID",
            TO_CHAR(longtodate(att.START_TIME),'yyyy-MM-dd HH24:MI:SS') "START_TIME",
            TO_CHAR(longtodate(att.STOP_TIME),'yyyy-MM-dd HH24:MI:SS')  "STOP_TIME",
            br.CENTER||'br'||br.id AS                                           "RESOURCE_ID",
            att.CENTER                                                          "CENTER_ID",
            REPLACE(TO_CHAR(att.LAST_MODIFIED,'FM999G999G999G999G999'),',','.') AS "ETS"
        FROM
            PARAMS, BOOKING_RESOURCES br
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
        AND att.LAST_MODIFIED BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
