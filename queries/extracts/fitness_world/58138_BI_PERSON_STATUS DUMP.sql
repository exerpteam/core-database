-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    biview.*
FROM
    (SELECT
    CAST ( PERSON_STATUS_LOG_ID AS VARCHAR(255)) AS                       "PERSON_STATUS_LOG_ID",
    PERSON_ID                                    AS                       "PERSON_ID",
    BI_DECODE_FIELD ('PERSONS','STATUS',STATEID) AS                       "PERSON_STATUS",
    TO_CHAR(longtodateC(FLOOR(START_TIME/1000)*1000,CENTER),'yyyy-MM-dd') "FROM_DATE",
    TO_CHAR(longtodateC(FLOOR(START_TIME/1000)*1000,CENTER),'hh24:mi:ss') "FROM_TIME",
    CENTER AS                                                             "CENTER_ID",
    ETS    AS                                                             "ETS"
FROM
    (
        SELECT
            scl.KEY        AS PERSON_STATUS_LOG_ID,
            cp.EXTERNAL_ID AS PERSON_ID,
            STATEID,
            scl.center AS CENTER,
            CASE
                WHEN STATEID IN (2) -- inactive
                THEN scl.BOOK_START_TIME
                ELSE scl.ENTRY_START_TIME
            END AS START_TIME,
            CASE
                WHEN STATEID IN (2) -- inactive
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
            scl.ENTRY_TYPE = 1 )scl) biview
WHERE
   biview.ETS >= $$FROMDATE$$ 
    AND biview.ETS < $$TODATE$$

