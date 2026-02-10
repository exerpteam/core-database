-- The extract is extracted from Exerp on 2026-02-08
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
    cp.EXTERNAL_ID                                                    AS "PERSON_ID",
    BI_DECODE_FIELD ('PERSONS','PERSONTYPE',scl.STATEID)              AS "PERSON_TYPE",
    TO_CHAR(longtodateC(scl.BOOK_START_TIME,scl.center),'yyyy-MM-dd') AS "FROM_DATE",
    scl.CENTER                                                        AS "CENTER_ID",
    REPLACE(TO_CHAR(scl.BOOK_START_TIME,'FM999G999G999G999G999'),',','.') AS "ETS"
FROM
    params,
    STATE_CHANGE_LOG scl
JOIN
    PERSONS p
ON
    p.center = scl.center
    AND p.id = scl.id
JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
WHERE
    scl.ENTRY_TYPE = 3
    AND NOT EXISTS
    (
        SELECT
            1
        FROM
            PERSONS p2
        JOIN
            STATE_CHANGE_LOG scl2
        ON
            scl2.center = p2.CENTER
            AND scl2.id = p2.id
            AND scl2.ENTRY_TYPE = 3
        WHERE
            p2.CURRENT_PERSON_CENTER = cp.center
            AND p2.CURRENT_PERSON_ID = cp.id
            AND scl2.ENTRY_TYPE =5
            AND BI_TRUNC_DATE(longtodateC(scl.BOOK_START_TIME,scl.center)) = BI_TRUNC_DATE(longtodateC(scl2.BOOK_START_TIME,scl2.center))
            AND scl2.ENTRY_START_TIME > scl.ENTRY_START_TIME
            AND (
                scl2.STATEID != 0
                OR scl2.center = scl.center))
    AND scl.BOOK_START_TIME BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
