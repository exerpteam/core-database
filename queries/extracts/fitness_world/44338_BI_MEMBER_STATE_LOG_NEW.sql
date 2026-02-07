-- This is the version from 2026-02-05
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
    (
SELECT
    CAST ( MEMBER_STATE_LOG_ID AS VARCHAR(255))         AS                "MEMBER_STATE_LOG_ID",
    PERSON_ID                                           AS                "PERSON_ID",
    BI_DECODE_FIELD ('PERSONS','MEMBER_STATUS',STATEID) AS                "MEMBER_STATE",
    TO_CHAR(longtodateC(FLOOR(START_TIME/1000)*1000,CENTER),'yyyy-MM-dd') "FROM_DATE",
    TO_CHAR(longtodateC(FLOOR(START_TIME/1000)*1000,CENTER),'hh24:mi:ss') "FROM_TIME",
    CENTER AS                                                             "CENTER_ID",
    ETS    AS                                                             "ETS"
FROM
    (
        SELECT
            scl.KEY        AS MEMBER_STATE_LOG_ID,
            cp.EXTERNAL_ID AS PERSON_ID,
            STATEID,
            scl.center AS CENTER,
            CASE
                WHEN STATEID IN (1,5,6) -- nonMember, exMember, legacyMember
                THEN scl.BOOK_START_TIME
                ELSE scl.ENTRY_START_TIME
            END AS START_TIME,
            CASE
                WHEN STATEID IN (1,5) -- nonMember, exMember
                THEN scl.BOOK_START_TIME
                ELSE scl.ENTRY_START_TIME
            END AS ETS
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
            scl.ENTRY_TYPE = 5 )scl) biview
WHERE
    biview.ETS BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
