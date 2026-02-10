-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (
        SELECT
            DECODE($$offset$$,-1,0,(TRUNC(exerpsysdate())-$$offset$$-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000) AS FROMDATE,
            (TRUNC(exerpsysdate()+1)-to_date('1-1-1970 00:00:00','MM-DD-YYYY HH24:Mi:SS'))*24*3600*1000                                 AS TODATE
        FROM
            dual
    )
SELECT
    biview.*
FROM
    params,
    (SELECT
    "HOME_CENTER_LOG_ID",
    "PERSON_ID",
    "HOME_CENTER_ID",
    "FROM_DATE",
    "FROM_TIME",
    "CENTER_ID",
    "ETS"
FROM
    (
        SELECT
            CAST ( scl.KEY AS VARCHAR(255))                                   AS "HOME_CENTER_LOG_ID",
            cp.EXTERNAL_ID                                                    AS "PERSON_ID",
            scl.center                                                        AS "HOME_CENTER_ID",
            TO_CHAR(longtodateC(scl.BOOK_START_TIME,scl.center),'yyyy-MM-dd') AS "FROM_DATE",
            TO_CHAR(longtodateC(scl.BOOK_START_TIME,scl.center),'hh24:mi:ss') AS "FROM_TIME",
            scl.CENTER                                                        AS "CENTER_ID",
            scl.BOOK_START_TIME                                               AS "ETS",
            CASE
                WHEN lead(scl.center) over (partition BY cp.EXTERNAL_ID ORDER BY scl.key DESC) = scl.center
                THEN 0
                ELSE 1
            END AS IS_FIRST
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
            scl.ENTRY_TYPE = 3) a
WHERE
    IS_FIRST = 1) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
