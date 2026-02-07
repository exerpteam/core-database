WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(SYSDATE)-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(SYSDATE+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                  AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    (
        SELECT
            dms.ID            AS "ID",
            cp.EXTERNAL_ID    AS "PERSON_ID",
            dms.PERSON_CENTER AS "CENTER_ID",
            dms.PERSON_ID     AS "HOME_CENTER_PERSON_ID",
            TO_CHAR(dms.CHANGE_DATE,'yyyy-MM-dd ')||TO_CHAR(longtodateC(dms.ENTRY_START_TIME,dms.PERSON_CENTER),'HH24:MI') AS "CHANGE_DATETIME",
            BI_DECODE_FIELD('DAILY_MEMBER_STATUS_CHANGES','CHANGE',dms.CHANGE)                                             AS "CHANGE",
            dms.MEMBER_NUMBER_DELTA                                                                                        AS "MEMBER_NUMBER_DELTA",
            dms.EXTRA_NUMBER_DELTA                                                                                         AS "EXTRA_NUMBER_DELTA",
            dms.SECONDARY_MEMBER_NUMBER_DELTA                                                                              AS "SECONDARY_MEMBER_NUMBER_DELTA",
            dms.ENTRY_START_TIME                                                                                           AS "ETS"
        FROM
            DAILY_MEMBER_STATUS_CHANGES dms
        JOIN
            PERSONS p
        ON
            p.CENTER = dms.PERSON_CENTER
            AND p.id = dms.PERSON_ID
        JOIN
            PERSONS cp
        ON
            cp.center = p.TRANSFERS_CURRENT_PRS_CENTER
            AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
        WHERE
            dms.ENTRY_STOP_TIME IS NULL) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE