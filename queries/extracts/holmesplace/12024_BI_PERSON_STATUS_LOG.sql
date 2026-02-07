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
    PERSON_ID AS "PERSON_ID",
    BI_DECODE_FIELD ('PERSONS','STATUS',STATEID) AS "PERSON_STATUS",
    FROM_DATE AS "FROM_DATE",
    CENTER_ID AS "CENTER_ID",
    ETS       AS "ETS"
FROM
    (
        SELECT
            PERSON_ID,
            STATEID,
            TO_CHAR(longtodateC(FLOOR(START_TIME/1000)*1000,CENTER),'yyyy-MM-dd')                                                FROM_DATE,
            CENTER                                                                                                               AS CENTER_ID,
            START_TIME                                                                                                           AS ETS,
            rank() over (partition BY PERSON_ID,BI_TRUNC_DATE(longtodateC(FLOOR(START_TIME/1000)*1000,CENTER)) ORDER BY START_TIME DESC) AS rnk
        FROM
            (
                SELECT
                    cp.EXTERNAL_ID AS PERSON_ID,
                    STATEID,
                    scl.center AS CENTER,
                    CASE
                        WHEN STATEID = 2
                        THEN scl.BOOK_START_TIME
                        ELSE scl.ENTRY_START_TIME
                    END AS START_TIME
                FROM
                    STATE_CHANGE_LOG scl
                JOIN
                    PERSONS p
                ON
                    p.center = scl.center
                    AND p.id = scl.id
                JOIN
                    PERSONS cp
                ON
                    cp.CENTER = p.TRANSFERS_CURRENT_PRS_CENTER
                    AND cp.id = p.TRANSFERS_CURRENT_PRS_ID
                WHERE
                    scl.ENTRY_TYPE = 1
                    AND (
                        scl.ENTRY_END_TIME >= (floor(ENTRY_START_TIME/(1000*60*60*24)) +1)*1000*60*60*24 -1
                        OR scl.ENTRY_END_TIME IS NULL))scl) scl
WHERE
    rnk=1) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE