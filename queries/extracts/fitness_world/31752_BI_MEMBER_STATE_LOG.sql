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
    PERSON_ID                                           AS "PERSON_ID",
    BI_DECODE_FIELD ('PERSONS','MEMBER_STATUS',STATEID) AS "MEMBER_STATE",
    FROM_DATE                                           AS "FROM_DATE",
    CENTER_ID                                           AS "CENTER_ID",
    REPLACE(TO_CHAR(ETS,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    (
        SELECT
            PERSON_ID,
            STATEID,
            TO_CHAR(longtodateC(FLOOR(START_TIME/1000)*1000,CENTER),'yyyy-MM-dd')                                                        FROM_DATE,
            CENTER                                                                                                                       AS CENTER_ID,
            START_TIME                                                                                                                   AS ETS,
            rank() over (partition BY PERSON_ID,BI_TRUNC_DATE(longtodateC(FLOOR(START_TIME/1000)*1000,CENTER)) ORDER BY START_TIME DESC) AS rnk
        FROM
            params,
            (
                SELECT
                    cp.EXTERNAL_ID AS PERSON_ID,
                    STATEID,
                    scl.center AS CENTER,
                    CASE
                        WHEN STATEID = 5
                        THEN scl.BOOK_START_TIME
                        WHEN stateid = 1
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
                    scl.ENTRY_TYPE = 5) scl2
                WHERE
                    scl2.START_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
             
                ) scl3
WHERE
    rnk=1
    
