-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    scl.KEY AS     "HOME_CENTER_LOG_ID",
    cp.EXTERNAL_ID "PERSON_ID",
    scl.center                                                                       AS  "HOME_CENTER_ID",
    TO_CHAR(BI_TRUNC_DATE(longtodateC(scl.BOOK_START_TIME,scl.center)),'yyyy-MM-dd') AS  "FROM_DATE",
    scl.center                                                                       AS  "CENTER_ID",
    Transfers.From_time                                                              AS  "ETS"
FROM
    PERSONS p
JOIN
    PERSONS cp
ON
    cp.CENTER = p.CURRENT_PERSON_CENTER
    AND cp.id = p.CURRENT_PERSON_ID
JOIN
    (
        SELECT
            EXTERNAL_ID,
            MAX(From_time) AS From_time
        FROM
            (
                SELECT
                    cp.EXTERNAL_ID,
                    p.center,
                    MIN(scl.BOOK_START_TIME) AS From_time
                FROM
                    PERSONS p
                JOIN
                    PERSONS cp
                ON
                    cp.CENTER = p.CURRENT_PERSON_CENTER
                    AND cp.id = p.CURRENT_PERSON_ID
                JOIN
                    STATE_CHANGE_LOG scl
                ON
                    scl.center = p.center
                    AND scl.id = p.id
                    AND scl.ENTRY_TYPE =5
                GROUP BY
                    cp.EXTERNAL_ID,
                    p.center,
                    p.id ) first_entries
        GROUP BY
            EXTERNAL_ID,
            BI_TRUNC_DATE(longtodateC(From_time,center))) Transfers
ON
    Transfers.EXTERNAL_ID = cp.EXTERNAL_ID
JOIN
    STATE_CHANGE_LOG scl
ON
    scl.center = p.center
    AND scl.id = p.id
    AND scl.ENTRY_TYPE =1
    AND Transfers.From_time = scl.BOOK_START_TIME
